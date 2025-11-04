

#include "screenshot.h"
#include "ScreenshotManager.h"
#include <QGuiApplication>
#include <QScreen>
#include <QPixmap>
#include <QDateTime>
#include <QCursor>
#include <QUrl>
#include <QDir>
#include <QNetworkReply>

extern ScreenshotManager* screenshotManager; // Declare as extern if global, or pass as pointer if you wire it up differently.

QString Screenshot::capture() {
    QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen) return "";

    QPixmap pixmap = screen->grabWindow(0);
    QString filename = QString("screenshot_%1.png")
                           .arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss"));
    pixmap.save(filename);

    QString fullPath = QDir::current().absoluteFilePath(filename);

    if (screenshotManager) {
        screenshotManager->setLastScreenshotPath(QUrl::fromLocalFile(fullPath).toString());
    }

    return fullPath;  // Return full screenshot path
}
