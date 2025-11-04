#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDate>

class DatabaseHelper : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseHelper(QObject *parent = nullptr);

    bool openDatabase();
    void createSettingsTable();
    void createTimerTable();

    // void saveTimerSeconds(int seconds);
    // int loadTimerSeconds();

    int loadTimerSeconds(const QString &userId);
    void saveTimerSeconds(const QString &userId, int seconds);


    void saveSettings(const QString &appName, const QString &iconPath);
    bool loadSettings(QString &appName, QString &iconPath);

private:
    QSqlDatabase db;
};
