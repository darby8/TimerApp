
#include "databasehelper.h"
#include <QStandardPaths>
#include <QDir>

DatabaseHelper::DatabaseHelper(QObject *parent)
    : QObject(parent)
{
    openDatabase();
    createSettingsTable();
    createTimerTable(); // create timer table at startup
}

// bool DatabaseHelper::openDatabase()
// {
//     if (QSqlDatabase::contains("settings_connection")) {
//         db = QSqlDatabase::database("settings_connection");
//     } else {
//         db = QSqlDatabase::addDatabase("QSQLITE", "settings_connection");
//         db.setDatabaseName("settings.db"); // local file
//     }

//     if (!db.open()) {
//         qWarning() << "Cannot open SQLite database:" << db.lastError().text();
//         return false;
//     }
//     return true;
// }




bool DatabaseHelper::openDatabase()
{
    QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(basePath);  // Ensure directory exists

    QString dbPath = basePath + "/settings.db";
    qDebug() << "Tracker DB Path:" << dbPath;

    if (QSqlDatabase::contains("settings_connection")) {
        db = QSqlDatabase::database("settings_connection");
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE", "settings_connection");
        db.setDatabaseName(dbPath);
    }

    if (!db.open()) {
        qWarning() << "Cannot open SQLite database:" << db.lastError().text();
        return false;
    }

    return true;
}


void DatabaseHelper::createSettingsTable()
{
    QSqlQuery query(db);
    QString createTable =
        "CREATE TABLE IF NOT EXISTS app_settings ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "application_name TEXT,"
        "icon_path TEXT"
        ")";
    if (!query.exec(createTable)) {
        qWarning() << "Failed to create table:" << query.lastError().text();
    }
}

void DatabaseHelper::createTimerTable()
{
    QSqlQuery query(db);
    QString createTable =
        "CREATE TABLE IF NOT EXISTS daily_timer ("
        "user_id TEXT,"
        "date TEXT,"
        "seconds INTEGER,"
        "PRIMARY KEY(user_id, date)"
        ")";
    if (!query.exec(createTable)) {
        qWarning() << "Failed to create daily_timer table:" << query.lastError().text();
    }
}

void DatabaseHelper::saveTimerSeconds(const QString &userId, int seconds)
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    QSqlQuery query(db);  // db is the class member

    query.prepare(
        "INSERT INTO daily_timer (user_id, date, seconds) VALUES (:user, :date, :sec) "
        "ON CONFLICT(user_id, date) DO UPDATE SET seconds=:sec"
        );
    query.bindValue(":user", userId);
    query.bindValue(":date", today);
    query.bindValue(":sec", seconds);

    if (!query.exec()) {
        qWarning() << "Failed to save timer for user" << userId << ":" << query.lastError().text();
    }
}



int DatabaseHelper::loadTimerSeconds(const QString &userId)
{
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    QSqlQuery query(db);

    query.prepare("SELECT seconds FROM daily_timer WHERE user_id=:user AND date=:date");
    query.bindValue(":user", userId);
    query.bindValue(":date", today);

    if (!query.exec()) {
        qWarning() << "Failed to load timer for user" << userId << ":" << query.lastError().text();
        return 0;
    }

    if (query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}



void DatabaseHelper::saveSettings(const QString &appName, const QString &iconPath)
{
    QSqlQuery clearQuery(db);
    clearQuery.exec("DELETE FROM app_settings");

    QSqlQuery query(db);
    query.prepare("INSERT INTO app_settings (application_name, icon_path) VALUES (:name, :icon)");
    query.bindValue(":name", appName);
    query.bindValue(":icon", iconPath);

    if (!query.exec()) {
        qWarning() << "Failed to insert settings:" << query.lastError().text();
    }
}

bool DatabaseHelper::loadSettings(QString &appName, QString &iconPath)
{
    QSqlQuery query(db);
    query.prepare("SELECT application_name, icon_path FROM app_settings LIMIT 1");

    if (!query.exec()) {
        qWarning() << "Failed to fetch settings:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        appName = query.value(0).toString();
        iconPath = query.value(1).toString();
        return true;
    }

    return false;
}
