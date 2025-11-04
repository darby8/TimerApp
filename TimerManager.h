#pragma once

#include <QObject>
#include <QTimer>
#include "databasehelper.h"
#include <QTimer>

class TimerManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int seconds READ seconds NOTIFY secondsChanged)
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

public:
    explicit TimerManager(DatabaseHelper* dbHelper, QObject* parent = nullptr);

    int seconds() const;
    bool isRunning() const;
    // void setCurrentUser(const QString &userId);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void loadSavedTime();
    Q_INVOKABLE void setCurrentUser(const QString &userId);

signals:
    void secondsChanged();
    void runningChanged();
     void aiSyncRequested();

private slots:
    void onTimeout();

private:
    int m_seconds;
    bool m_running;
    QTimer m_timer;
    QTimer syncTimer;
    DatabaseHelper* m_dbHelper;
    QString m_currentUser;

    QTimer m_aiTimer;     // new (AI sync)
    int m_aiSyncPeriod = 0;



};

