
#ifndef TRACKER_H
#define TRACKER_H

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSqlDatabase>
#include <QJsonObject>
#include "databasehelper.h"
#include "ScreenshotManager.h"
class Tracker : public QObject {
    Q_OBJECT
    // add this QTimer for scheduling a single capture inside each base window

    Q_PROPERTY(QString getAccessToken READ getAccessToken NOTIFY accessTokenChanged)
    Q_PROPERTY(QString lastCaptureTime READ lastCaptureTime NOTIFY lastCaptureTimeChanged)
    Q_PROPERTY(QString appName READ appName NOTIFY appNameChanged)


public:
    explicit Tracker(QObject *parent = nullptr);


    Q_INVOKABLE void setAccessToken(const QString &token);
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void fetchData(const QString &token);
    QString appName() const { return m_appName; }
    QString appIcon() const { return m_appIcon; }
    QString getAccessToken();
    QString lastCaptureTime() const { return m_lastCaptureTime; }
     void setCurrentUser(const QString &userId);
    void initLocalDatabase();
    void syncPendingEvents();
    void saveEventToLocalDb(const QJsonObject &event);
    QString getLastScreenshotForUser(const QString &userId);
    void setSyncPeriod(int milliseconds);

    Q_PROPERTY(int aiSyncPeriod READ aiSyncPeriod WRITE setAiSyncPeriod NOTIFY aiSyncPeriodChanged)

    int aiSyncPeriod() const { return m_aiSyncPeriod; }
    void setAiSyncPeriod(int period);




signals:
    void lastCaptureTimeChanged();
    void accessTokenChanged();
    void applicationNameChanged(QString name);
    // void appNameChanged();
    void appNameChanged(QString name);
    void appIconChanged(QString icon);
     void aiSyncPeriodChanged(int newPeriod);
      void aiSyncRequested();


private slots:
    void onTrackerTimeout();


private:
    int m_aiSyncPeriod = 0;
    QString m_appName;
    QString m_appIcon;
    void captureAndSend();
    void saveLastCaptureTimeForUser(const QString &userId, const QString &time);
    QString getLastCaptureTimeForUser(const QString &userId);
    QString getCachedIconPath(const QString &url);
    QSqlDatabase db;
    QTimer trackerTimer;
    bool isRunning = false;
    QString m_accessToken;
    QString m_lastCaptureTime;   // store formatted time
    QNetworkAccessManager *networkManager;
    DatabaseHelper dbHelper;
    QSqlDatabase m_db;
    bool hasPending = false;
    QTimer syncTimer;
    QString m_currentUser;
    ScreenshotManager m_screenshotManager;

    int minInterval = 1000;  // 5 sec
    int maxInterval = 10000; // 10 sec


    QTimer shotTimer;      // schedules actual screenshot

    QTimer m_timer;       // existing main timer
    QTimer m_aiTimer;     // new timer for AI sync




};

#endif // TRACKER_H
