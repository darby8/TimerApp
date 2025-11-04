#ifndef SCRIPTHELPER_H
#define SCRIPTHELPER_H

#include <QObject>
#include <QString>

class ScriptHelper : public QObject {
    Q_OBJECT
public:
    explicit ScriptHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString getAccessToken() const { return m_token; }
    Q_INVOKABLE void setAccessToken(const QString &token) { m_token = token; }

private:
    QString m_token;
};

#endif // SCRIPTHELPER_H
