
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>

#include "tracker.h"
#include "TimerManager.h"
#include "ScreenshotManager.h"
#include "databasehelper.h"
#include "singleapplication.h"
#include "tracker.h"
// Global pointer for ScreenshotManager
ScreenshotManager* screenshotManager = nullptr;

// Global Tracker instance
Tracker tracker;

int main(int argc, char *argv[])
{
    // QApplication app(argc, argv);
    SingleApplication app(argc, argv);
    app.setApplicationName("Productivity Tracker");
    // app.setWindowIcon(QIcon("../../icons/pulse.svg"));


    DatabaseHelper dbHelper;
    TimerManager timerManager(&dbHelper);
    timerManager.loadSavedTime();

    // --- Create ScreenshotManager ---
    ScreenshotManager manager;
    screenshotManager = &manager; // global pointer for other code

    // --- Expose objects to QML ---
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("tracker", &tracker);
    engine.rootContext()->setContextProperty("TimerManager", &timerManager);
    engine.rootContext()->setContextProperty("ScreenshotManager", screenshotManager);

    const QUrl url(QStringLiteral("qrc:/project-overwatch/QML/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.load(url);

    // --- Save timer when app closes ---
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&]() {
        timerManager.stop(); // stops timer & saves time
    });

    return app.exec();
}

