#pragma once
#include <QObject>
#include <QString>

class ScreenshotManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastScreenshotPath READ lastScreenshotPath NOTIFY lastScreenshotPathChanged)
public:
    explicit ScreenshotManager(QObject* parent = nullptr)
        : QObject(parent)
    {}

    QString lastScreenshotPath() const { return m_lastScreenshotPath; }

    void setLastScreenshotPath(const QString& path) {
        if (m_lastScreenshotPath != path) {
            m_lastScreenshotPath = path;
            emit lastScreenshotPathChanged();
        }
    }

signals:
    void lastScreenshotPathChanged();

private:
    QString m_lastScreenshotPath;
};
