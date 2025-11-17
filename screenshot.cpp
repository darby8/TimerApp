

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
#include <QStandardPaths>

extern ScreenshotManager* screenshotManager; // Declare as extern if global, or pass as pointer if you wire it up differently.

// QString Screenshot::capture() {
//     QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
//     if (!screen) return "";

//     QPixmap pixmap = screen->grabWindow(0);
//     QString filename = QString("screenshot_%1.png")
//                            .arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss"));
//     pixmap.save(filename);

//     QString fullPath = QDir::current().absoluteFilePath(filename);

//     if (screenshotManager) {
//         screenshotManager->setLastScreenshotPath(QUrl::fromLocalFile(fullPath).toString());
//     }
//     qDebug() << "fullPath DB Path:" << fullPath;
//     return fullPath;  // Return full screenshot path
// }



QString Screenshot::capture()
{
    QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen) {
        qWarning() << "[Screenshot] No screen detected!";
        return "";
    }

    // --- Get correct cross-platform AppData path ---
    QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // --- Save screenshots inside "screenshots" subfolder ---
    QString screenshotDir = basePath + "/screenshots";
    QDir().mkpath(screenshotDir);

    // --- Generate filename ---
    QString filename = QString("screenshot_%1.png")
                           .arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss"));

    QString fullPath = screenshotDir + "/" + filename;

    // --- Capture ---
    QPixmap pixmap = screen->grabWindow(0);

    if (!pixmap.save(fullPath)) {
        qWarning() << "[Screenshot] Failed to save:" << fullPath;
        return "";
    }

    qDebug() << "[Screenshot] Saved to:" << fullPath;

    // --- Update ScreenshotManager ---
    if (screenshotManager) {
        screenshotManager->setLastScreenshotPath(QUrl::fromLocalFile(fullPath).toString());
    }

    return fullPath;
}
