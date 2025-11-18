#include "tracker.h"
#include "screenshot.h"
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QFileInfo>
#include <QDebug>
#include <thread>
#include <uiohook.h>
#include <QSet>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QTemporaryFile>
#include <QTimer>
#include <QCoreApplication>
#include <QApplication>
#include "ScreenshotManager.h"
#include <QIcon>
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QTimer>
#include <QStandardPaths>
#include <QDir>
Tracker tracker;
extern ScreenshotManager* screenshotManager;
// ---------- static state (counters, key set) ----------
static QString accessToken;
static int mouseClickCount = 0;
static int keyPressCount = 0;
static int uniqueKeyCount = 0;
static int alphaNumericKeyCount = 0;
static int specialCharCount = 0;
static QSet<int> pressedKeys;
// Single shared network manager for all requests (allocated in ctor)
static QNetworkAccessManager *g_networkManager = nullptr;
// Serialize outgoing flushes so we only have one in-flight DB row at a time
static bool g_flushInProgress = false;
// Forward declarations for helpers inside this cpp
static void initLocalDatabase(); // creates DB and table
static qint64 insertEventToDb(const QJsonObject &event,const QString &userId); // returns last insert id or -1
static void markEventSynced(qint64 id);
static void deleteOldSyncedRows(const QString &userId);

static void sendDbRowAsync(qint64 id,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      int mouseClicks, int keyClicks,
                           int uniqueKeys, int alnumKeys, int specialChars,
                           const QString &screenshotPath, std::function<void(bool,qint64)> done);
// Helper: check special char keys (uiohook keycodes)
static bool isSpecialCharacterKey(int keycode) {
    switch (keycode) {
    case VC_1: case VC_2: case VC_3: case VC_4: case VC_5:
    case VC_6: case VC_7: case VC_8: case VC_9: case VC_0:
    case VC_MINUS: case VC_EQUALS: case VC_BACK_SLASH:
    case VC_OPEN_BRACKET: case VC_CLOSE_BRACKET: case VC_SEMICOLON:
    case VC_QUOTE: case VC_COMMA: case VC_PERIOD: case VC_SLASH:
        return true;
    default:
        return false;
    }
}


extern void updateAppMeta(const QString &name);
// ----------------- Global hook handler -----------------
static void handle_event(uiohook_event * const event) {
    if (event->type == EVENT_KEY_PRESSED) {
        keyPressCount++;
        int keycode = event->data.keyboard.keycode;
        pressedKeys.insert(keycode);
        if ((keycode >= VC_A && keycode <= VC_Z) ||
            (keycode >= VC_0 && keycode <= VC_9)) {
            alphaNumericKeyCount++;
        } else if (isSpecialCharacterKey(keycode)) {
            specialCharCount++;
        }
    } else if (event->type == EVENT_MOUSE_PRESSED) {
        mouseClickCount++;
    }
}
// ----------------- Tracker implementation -----------------
Tracker::Tracker(QObject *parent)
    : QObject(parent)
{

    connect(&m_aiTimer, &QTimer::timeout, this, [this](){
        qDebug() << "[TimerManager] AI sync triggered";
        emit aiSyncRequested(); // signal for QML to run Script function
    });

     networkManager = new QNetworkAccessManager(this);
    // prepare a single manager (will be used by send logic)
    if (!g_networkManager) {
        g_networkManager = new QNetworkAccessManager(this);
    }
    // create DB & table (safe to call multiple times)
    initLocalDatabase();
    // prepare timer but DO NOT start it here — start() controls running state
    // trackerTimer.setInterval(10000); // 10 seconds
    // trackerTimer.setSingleShot(false);
    // connect(&trackerTimer, &QTimer::timeout, this, &Tracker::captureAndSend);

    // base window timer
    trackerTimer.setSingleShot(false);
    connect(&trackerTimer, &QTimer::timeout, this, &Tracker::onTrackerTimeout);

    // shot timer for random capture
    shotTimer.setSingleShot(true);
    connect(&shotTimer, &QTimer::timeout, this, &Tracker::captureAndSend);

    // periodic sync timer
    syncTimer.setInterval(5000);
    syncTimer.setSingleShot(false);
    connect(&syncTimer, &QTimer::timeout, this, &Tracker::syncPendingEvents);

    // try flushing immediately at startup
    // QTimer::singleShot(0, this, &Tracker::syncPendingEvents);

}

void Tracker::onTrackerTimeout() {
    if (!isRunning) return;

    int base = trackerTimer.interval();
    int jitter = QRandomGenerator::global()->bounded(minInterval, base + 1);

    qDebug() << "[Tracker] scheduling capture in" << jitter << "ms (window=" << base << "ms)";

    shotTimer.start(jitter);
}

void Tracker::start() {
    if (isRunning) return;
    isRunning = true;

    std::thread([] {
        hook_set_dispatch_proc(handle_event);
        hook_run();
    }).detach();

    trackerTimer.setInterval(maxInterval);  // base window length from API
    trackerTimer.start();
    onTrackerTimeout();
    syncTimer.start();
    QTimer::singleShot(0, this, &Tracker::syncPendingEvents);

    qDebug() << "[Tracker] started. Base window (period) =" << trackerTimer.interval() << "ms";
}


void Tracker::setAccessToken(const QString &token) {
    m_accessToken = token;
    accessToken = token;
    qDebug() << "[Tracker] Access token updated.";
    emit accessTokenChanged();
}
QString Tracker::getAccessToken() {
    return m_accessToken;
}

void Tracker::stop() {
    if (!isRunning) return;
    isRunning = false;
    trackerTimer.stop();
    hook_stop();
    qDebug() << "[Tracker] stopped.";
    syncTimer.stop();
    // syncPendingEvents();
}
void Tracker::captureAndSend() {
    // Safety: do nothing unless explicitly started
    if (!isRunning) return;
    // 1) Capture screenshot (Screenshot::capture returns full path)
    QString screenshotPath = Screenshot::capture();
    if (screenshotPath.isEmpty()) {
        qWarning() << "[Tracker] capture failed - no screenshot path.";
        return;
    }
    // 2) Read the file bytes then close immediately
    QByteArray imageBytes;
    {
        QFile f(screenshotPath);
        if (f.open(QIODevice::ReadOnly)) {
            imageBytes = f.readAll();
            f.close();
        } else {
            qWarning() << "[Tracker] Could not open screenshot file for reading:" << screenshotPath;
            // still proceed to store path (or you may choose to abort)
        }
    }
    // 3) Prepare event object
    uniqueKeyCount = pressedKeys.size();
    QJsonObject event;
    event["timestamp"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    event["mouse_clicks"] = mouseClickCount;
    event["key_clicks"] = keyPressCount;
    event["unique_keys"] = uniqueKeyCount;
    event["alphanumeric_keys"] = alphaNumericKeyCount;
    event["special_char"] = specialCharCount;
    event["screenshot_path"] = screenshotPath; // store path, not inline base64
    // 4) Save to DB (always)


     qDebug() << "data saved" << event;


    qint64 rowId = insertEventToDb(event,m_currentUser);
    if (rowId < 0) {
        qWarning() << "[Tracker] Failed to insert event to DB.";
    } else {
        qDebug() << "[Tracker] Saved event id=" << rowId;
    }
    // 5) update UI time and reset counters
    QString currentTime = QDateTime::currentDateTime().toString("hh:mm AP");
    if (m_lastCaptureTime != currentTime) {
        m_lastCaptureTime = currentTime;
        saveLastCaptureTimeForUser(m_currentUser, currentTime);
        emit lastCaptureTimeChanged();
    }
    mouseClickCount = keyPressCount = uniqueKeyCount = alphaNumericKeyCount = specialCharCount = 0;
    pressedKeys.clear();
    // 6) Try to flush pending DB rows (will only send while not already flushing)
    // QTimer::singleShot(0, this, &Tracker::syncPendingEvents);
}
// ----------------- Database helpers -----------------
static const QString DB_CONN_NAME = QStringLiteral("tracker_connection");
static const QString DB_FILENAME = QStringLiteral("tracker_local.db");

void Tracker::setCurrentUser(const QString &userId) {
    m_currentUser = userId;
    qDebug() << "Current user set to:" << m_currentUser;


    m_lastCaptureTime = getLastCaptureTimeForUser(userId);
    emit lastCaptureTimeChanged();

    // 🔹 Load last screenshot from DB
    QString lastPath = getLastScreenshotForUser(userId);
    if (!lastPath.isEmpty() && screenshotManager) {
        screenshotManager->setLastScreenshotPath(QUrl::fromLocalFile(lastPath).toString());
         qDebug() << "[Tracker] Setting last screenshot path:" << QUrl::fromLocalFile(lastPath).toString();
    }


    qDebug() << "Current user set to:" << m_currentUser;
    qDebug() << "Last screenshot path loaded:" << lastPath;



}


void Tracker::initLocalDatabase() {
    // Avoid duplicate connections
    // if (QSqlDatabase::contains("tracker_connection")) {
    //     m_db = QSqlDatabase::database("tracker_connection");
    // } else {
    //     m_db = QSqlDatabase::addDatabase("QSQLITE", "tracker_connection");
    //     m_db.setDatabaseName("tracker.db");
    // }
    // if (!m_db.open()) {
    //     qWarning() << "[DB] Failed to open database:" << m_db.lastError();
    //     return;
    // }




    QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(basePath);

    QString dbPath = basePath + "/tracker.db";
    qDebug() << "tracker DB Path:" << dbPath;


    if (QSqlDatabase::contains("tracker_connection")) {
        m_db = QSqlDatabase::database("tracker_connection");
    } else {
        m_db = QSqlDatabase::addDatabase("QSQLITE", "tracker_connection");
        m_db.setDatabaseName(dbPath);
    }

    if (!m_db.open()) {
        qWarning() << "[DB] Failed to open database:" << m_db.lastError();
        return;
    }







    QSqlQuery query(m_db);

    QSqlQuery check(m_db);
    if (check.exec("PRAGMA table_info(tracker_events)")) {
        bool hasUserId = false;
        while (check.next()) {
            if (check.value(1).toString() == "user_id") {
                hasUserId = true;
                break;
            }
        }
        if (!hasUserId) {
            qDebug() << "[DB] Migrating table: adding user_id column";
            QSqlQuery alter(m_db);
            if (!alter.exec("ALTER TABLE tracker_events ADD COLUMN user_id TEXT")) {
                qWarning() << "[DB] Failed to alter table:" << alter.lastError();
            }
        }
    }

    if (!query.exec(
            "CREATE TABLE IF NOT EXISTS tracker_events ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "user_id TEXT,"
            "timestamp TEXT,"
            "mouse_clicks INTEGER,"
            "key_clicks INTEGER,"
            "unique_keys INTEGER,"
            "alphanumeric_keys INTEGER,"
            "special_char INTEGER,"
            "screenshot_path TEXT,"
            "synced INTEGER DEFAULT 0"
            ")"
            )) {
        qWarning() << "[DB] Failed to create table:" << query.lastError();
    } else {
        qDebug() << "[DB] activity_events table ready.";
    }
    if (!query.exec(
            "CREATE TABLE IF NOT EXISTS user_settings ("
            "user_id TEXT PRIMARY KEY,"
            "last_capture_time TEXT"
            ")"
            )) {
        qWarning() << "[DB] Failed to create user_settings table:" << query.lastError();
    }

}
static qint64 insertEventToDb(const QJsonObject &event, const QString &userId) {
    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) {
        qWarning() << "[DB] insertEventToDb: DB not open";
        return -1;
    }
    QSqlQuery query(db);
    query.prepare(R"(
        INSERT INTO tracker_events
        ( user_id, timestamp, mouse_clicks, key_clicks, unique_keys, alphanumeric_keys, special_char, screenshot_path, synced)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(userId);
    query.addBindValue(event["timestamp"].toString());
    query.addBindValue(event["mouse_clicks"].toInt());
    query.addBindValue(event["key_clicks"].toInt());
    query.addBindValue(event["unique_keys"].toInt());
    query.addBindValue(event["alphanumeric_keys"].toInt());
    query.addBindValue(event["special_char"].toInt());
    query.addBindValue(event["screenshot_path"].toString());
    query.addBindValue(0); // synced flag
    if (!query.exec()) {
        qWarning() << "[DB] insert failed:" << query.lastError().text();
        return -1;
    }
    QSqlQuery q2(db);
    if (q2.exec("SELECT last_insert_rowid()") && q2.next()) {
        return q2.value(0).toLongLong();
    }
    return -1;
}
static void markEventSynced(qint64 id) {
    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) return;
    QSqlQuery q(db);
    q.prepare("UPDATE tracker_events SET synced = 1 WHERE id = ?");
    q.addBindValue(id);
    if (!q.exec()) qWarning() << "[DB] markEventSynced failed:" << q.lastError().text();
}
static void deleteOldSyncedRows(const QString &userId) {
    if (userId.isEmpty()) {
        qWarning() << "[DB] No user set, skipping deleteOldSyncedRows.";
        return;
    }

    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) return;

    QSqlQuery q(db);
    q.prepare(R"(
        DELETE FROM tracker_events
        WHERE synced = 1
          AND user_id = ?
          AND timestamp < datetime('now', '-7 days')
    )");
    q.addBindValue(userId);

    if (!q.exec()) {
        qWarning() << "[DB] Failed to delete old synced rows:" << q.lastError().text();
    } else {
        qDebug() << "[DB] Deleted old synced rows for user:" << userId;
    }
}


void Tracker::syncPendingEvents() {
    if (m_currentUser.isEmpty()) {
        qWarning() << "[Tracker] No current user set, skipping sync.";
        return;
    }

    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) {
        qWarning() << "[DB] Cannot sync events — DB not open";
        return;
    }

    QSqlQuery query(db);
    query.prepare(R"(
        SELECT id, timestamp, mouse_clicks, key_clicks, unique_keys,
               alphanumeric_keys, special_char, screenshot_path
        FROM tracker_events
        WHERE synced = 0 AND user_id = ?
        ORDER BY id DESC
    )");
    query.addBindValue(m_currentUser);

    if (!query.exec()) {
        qWarning() << "[DB] Failed to fetch unsynced events:" << query.lastError().text();
        return;
    }

    struct Row {
        qint64 id;
        QString timestamp;
        int mouseClicks, keyClicks, uniqueKeys, alnumKeys, specialChars;
        QString screenshotPath;
    };
    QVector<Row> rows;
    while (query.next()) {
        Row r;
        r.id            = query.value(0).toLongLong();
        r.timestamp     = query.value(1).toString();
        r.mouseClicks   = query.value(2).toInt();
        r.keyClicks     = query.value(3).toInt();
        r.uniqueKeys    = query.value(4).toInt();
        r.alnumKeys     = query.value(5).toInt();
        r.specialChars  = query.value(6).toInt();
        r.screenshotPath= query.value(7).toString();
        rows.append(r);
    }

    if (rows.isEmpty()) {
        qDebug() << "[Tracker] No pending events to sync for user:" << m_currentUser;
        return;
    }

    qDebug() << "[Tracker] Syncing" << rows.size() << "pending events for user:" << m_currentUser;

    auto sendNext = [this, rows](int index, auto &&sendNextRef) -> void {
        if (index >= rows.size()) {
            qDebug() << "[Tracker] Sync complete for user:" << m_currentUser;
            return;
        }
        const Row r = rows[index];
        sendDbRowAsync(
            r.id,
            r.mouseClicks, r.keyClicks,
            r.uniqueKeys, r.alnumKeys, r.specialChars,
            r.screenshotPath,
            [this, index, &sendNextRef, r](bool success) {
                if (success) {
                    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
                    if (db.isOpen()) {
                        QSqlQuery delQuery(db);
                        delQuery.prepare("DELETE FROM tracker_events WHERE id = ? AND user_id = ?");
                        delQuery.addBindValue(r.id);
                        delQuery.addBindValue(m_currentUser);
                        if (!delQuery.exec()) {
                            qWarning() << "[DB] Failed to delete row after sync:" << delQuery.lastError().text();
                        } else {
                            qDebug() << "[DB] Deleted synced row with id:" << r.id << "for user:" << m_currentUser;
                        }
                    }
                } else {
                    qWarning() << "[Tracker] Failed to sync row id:" << r.id << "for user:" << m_currentUser;
                }
                sendNextRef(index + 1, sendNextRef);
            }
            );
    };
    sendNext(0, sendNext);
}


// Asynchronously send one DB row; callback will mark row synced on success and then call syncPendingEvents again
static void sendDbRowAsync(qint64 id,
                           int mouseClicks, int keyClicks,
                           int uniqueKeys, int alnumKeys, int specialChars,
                           const QString &screenshotPath, std::function<void(bool)> done)
{
    if (!g_networkManager) {
        qWarning() << "[Network] No network manager available";
        done(false);
        return;
    }
    QUrl url("https://backend-oversight.reak.co.in/api/activity-tracker");
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", ("Bearer " + accessToken).toUtf8());
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    auto addField = [&](const QString &name, const QString &value) {
        QHttpPart p;
        p.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"%1\"").arg(name)));
        p.setBody(value.toUtf8());
        multiPart->append(p);
    };
    addField("timestamp", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    addField("keyboard", QString::number(keyClicks));
    addField("mouse", QString::number(mouseClicks));
    addField("unique_keys", QString::number(uniqueKeys));
    addField("alphanumeric_keys", QString::number(alnumKeys));
    addField("special_char", QString::number(specialChars));
    QFileInfo fi(screenshotPath);
    QFile *file = nullptr;
    if (!screenshotPath.isEmpty() && fi.exists()) {
        QHttpPart filePart;
        filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                           QVariant(QString("form-data; name=\"image\"; filename=\"%1\"").arg(fi.fileName())));
        filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/png"));
        file = new QFile(screenshotPath);
        if (file->open(QIODevice::ReadOnly)) {
            filePart.setBodyDevice(file);
            file->setParent(multiPart); // ensure file gets deleted with multiPart when reply finished
            multiPart->append(filePart);
        } else {
            qWarning() << "[API] Could not open screenshot file for upload:" << screenshotPath;
            delete file; file = nullptr;
        }
    }
    QNetworkReply *reply = g_networkManager->post(request, multiPart);
    multiPart->setParent(reply); // reply will own multiPart (and the file)

    QObject::connect(reply, &QNetworkReply::finished, [reply, id, screenshotPath]() {
        bool ok = (reply->error() == QNetworkReply::NoError);
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray resp = reply->readAll();

        if (ok) {
            qDebug() << "[API] Sent id=" << id << " status=" << statusCode << " resp=" << resp;

            // Mark row as synced
            markEventSynced(id);

            if (!screenshotPath.isEmpty()) {
                QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
                if (db.isOpen()) {
                    QSqlQuery q(db);
                    q.prepare(R"(
                SELECT screenshot_path
                FROM tracker_events
                WHERE user_id = (
                    SELECT user_id FROM tracker_events WHERE id = ?
                )
                AND screenshot_path IS NOT NULL
                AND screenshot_path != ''
                AND synced = 1
                ORDER BY id DESC
            )");
                    q.addBindValue(id);

                    if (q.exec()) {
                        bool first = true;
                        while (q.next()) {
                            QString path = q.value(0).toString();
                            if (first) {
                                // 🟢 keep the newest screenshot
                                qDebug() << "[FS] Keeping latest screenshot:" << path;
                                first = false;
                                continue;
                            }
                            // 🔴 delete all older synced screenshots
                            if (!path.isEmpty() && QFile::exists(path)) {
                                QFile::remove(path);
                                qDebug() << "[FS] Deleted old screenshot:" << path;
                            }
                        }
                    }
                }
            }
        }
        reply->deleteLater();
        QTimer::singleShot(0, qApp, [] {
            const auto topLevel = qApp->topLevelWidgets();
            Q_UNUSED(topLevel);
        });
    });

}


QString Tracker::getLastScreenshotForUser(const QString &userId) {
    if (userId.isEmpty()) return "";

    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) return "";

    QSqlQuery q(db);
    q.prepare(R"(
        SELECT screenshot_path
        FROM tracker_events
        WHERE user_id = ? AND screenshot_path IS NOT NULL AND screenshot_path != ''
        ORDER BY id DESC
        LIMIT 1
    )");
    q.addBindValue(userId);
    if (q.exec() && q.next()) {
        return q.value(0).toString();
    }
    return "";
}




void Tracker::saveLastCaptureTimeForUser(const QString &userId, const QString &time) {
    if (userId.isEmpty()) return;
    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) return;

    QSqlQuery q(db);
    q.prepare(R"(
        INSERT INTO user_settings (user_id, last_capture_time)
        VALUES (?, ?)
        ON CONFLICT(user_id) DO UPDATE SET last_capture_time = excluded.last_capture_time
    )");
    q.addBindValue(userId);
    q.addBindValue(time);
    if (!q.exec()) {
        qWarning() << "[DB] Failed to save last capture time:" << q.lastError();
    }
}

QString Tracker::getLastCaptureTimeForUser(const QString &userId) {
    if (userId.isEmpty()) return "";

    QSqlDatabase db = QSqlDatabase::database(DB_CONN_NAME);
    if (!db.isOpen()) return "";

    QSqlQuery q(db);
    q.prepare("SELECT last_capture_time FROM user_settings WHERE user_id = ?");
    q.addBindValue(userId);
    if (q.exec() && q.next()) {
        return q.value(0).toString();
    }
    return "";
}


void Tracker::fetchData(const QString &token)
{
    if (!networkManager) {
        qWarning() << "[FS] networkManager is null! Cannot send request.";
        return;
    }

    QNetworkRequest request(QUrl("https://backend-oversight.reak.co.in/api/globalsettings"));

    // ✅ Send token in Authorization header
    request.setRawHeader("Authorization", "Bearer " + token.toUtf8());

    QNetworkReply *reply = networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this,reply]() {
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[FS] HTTP Status:" << statusCode;

        QByteArray raw = reply->readAll();
        qDebug().noquote() << "[FS] Raw API response:" << QString::fromUtf8(raw);

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(raw, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            qWarning() << "[FS] JSON parse error:" << parseError.errorString();
            reply->deleteLater();
            return;
        }

        if (!doc.isObject()) {
            qWarning() << "[FS] Response is not a JSON object!";
            reply->deleteLater();
            return;
        }

        QJsonObject root = doc.object();

        if (root.contains("payload") && root.value("payload").isObject()) {
            QJsonObject payload = root.value("payload").toObject();

            // ✅ Extract globalsettings safely
            if (payload.contains("globalsettings") && payload.value("globalsettings").isObject()) {
                QJsonObject global = payload.value("globalsettings").toObject();

                QString appName = global.value("app_name").toString();
                QString iconPath = global.value("app_icon").toString();

                qDebug() << "[FS] Setting app name to:" << appName << "and icon to:" << iconPath;

                // Update app name
                QCoreApplication::setApplicationName(appName);
                m_appName = appName;
                emit appNameChanged(m_appName);

                // Handle icon (cache + download)
                QString localIconPath = getCachedIconPath(iconPath);

                if (QFile::exists(localIconPath)) {
                    qDebug() << "[FS] Using cached icon:" << localIconPath;
                    QGuiApplication::setWindowIcon(QIcon(localIconPath));
                    m_appIcon = localIconPath;
                    emit appIconChanged(m_appIcon);
                } else {
                    qDebug() << "[FS] Downloading icon from:" << iconPath;
                    QNetworkRequest iconRequest = QNetworkRequest(QUrl(iconPath));  // ✅ Works too

                    QNetworkReply *iconReply = networkManager->get(iconRequest);

                    connect(iconReply, &QNetworkReply::finished, this, [this, iconReply, localIconPath]() {
                        if (iconReply->error() == QNetworkReply::NoError) {
                            QByteArray data = iconReply->readAll();
                            QFile file(localIconPath);
                            if (file.open(QIODevice::WriteOnly)) {
                                file.write(data);
                                file.close();
                                qDebug() << "[FS] Icon saved to cache:" << localIconPath;

                                QGuiApplication::setWindowIcon(QIcon(localIconPath));
                                m_appIcon = localIconPath;
                                emit appIconChanged(m_appIcon);
                            }
                        } else {
                            qWarning() << "[FS] Failed to download icon:" << iconReply->errorString();
                        }
                        iconReply->deleteLater();
                    });
                }

            }
            // ✅ Extract user group settings
            if (payload.contains("usergroupsettings") && payload.value("usergroupsettings").isObject()) {
                QJsonObject userGroup = payload.value("usergroupsettings").toObject();
                int syncPeriods = userGroup.value("sync_gap").toInt();
                int aiSyncPeriod  = userGroup.value("ai_sync_period").toInt();
                qDebug() << "[FS] User Group Settings:"
                         << "sync_gap =" << syncPeriods
                         << ", ai_sync_period =" << aiSyncPeriod;

                if (syncPeriods > 0) {
                    setSyncPeriod(syncPeriods * 1000); // ✅ use setter
                }
                if (aiSyncPeriod > 0) {
                    setAiSyncPeriod(aiSyncPeriod);     // ✅ new setter
                }
            }
        } else {
            qWarning() << "[FS] No payload object in JSON!";
        }

        reply->deleteLater();
    });
}

void Tracker::setAiSyncPeriod(int period) {
    if (m_aiSyncPeriod != period) {
        m_aiSyncPeriod = period;
        emit aiSyncPeriodChanged(m_aiSyncPeriod);
    }
}


void Tracker::setSyncPeriod(int milliseconds)
{
    if (milliseconds > 0) {
        maxInterval = milliseconds;
        minInterval = milliseconds / 10;   // e.g. 10% of max
        syncTimer.setInterval(milliseconds / 2);

        qDebug() << "[FS] Sync timer interval updated. "
                 << "Base window =" << maxInterval << "ms, "
                 << "random range =" << minInterval << "-" << maxInterval << "ms";

        if (isRunning) {
            // Just restart the *base window timer* (fixed interval)
            trackerTimer.setInterval(maxInterval);
            if (!trackerTimer.isActive()) {
                trackerTimer.start();
            }
            // Schedule first capture in this new window immediately
            onTrackerTimeout();
        }
    } else {
        qWarning() << "[FS] Invalid sync period. Keeping existing range between"
                   << minInterval << "and" << maxInterval;
    }
}



QString Tracker::getCachedIconPath(const QString &url)
{
    QByteArray hash = QCryptographicHash::hash(url.toUtf8(), QCryptographicHash::Md5);
    QString fileName = QString(hash.toHex());

    // Detect extension from URL
    QString extension = "svg";  // fallback
    int lastDot = url.lastIndexOf('.');
    if (lastDot != -1 && lastDot < url.length() - 1) {
        extension = url.mid(lastDot + 1);  // e.g., "png", "ico", "jpg"
    }

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir dir(cacheDir);
    if (!dir.exists())
        dir.mkpath(cacheDir);

    return cacheDir + "/" + fileName + "." + extension;
}



