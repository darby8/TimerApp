
cmake_minimum_required(VERSION 3.16)

project(project-overwatch VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6  REQUIRED COMPONENTS Quick Charts Sql Network)

set(QML_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/qml")
set(QML2_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/qml")

add_subdirectory(vendor/libuiohook)
set(QAPPLICATION_CLASS QApplication CACHE STRING "Inheritance class for SingleApplication")
add_subdirectory(singleapplication)

qt_standard_project_setup()

qt_add_executable(appproject-overwatch
    main.cpp
    screenshot.cpp
)


qt_add_resources(APP_RESOURCES resources.qrc)
target_sources(appproject-overwatch PRIVATE ${APP_RESOURCES})


qt_add_qml_module(appproject-overwatch
    URI project-overwatch
    VERSION 1.0

    SOURCES tracker.h
    SOURCES tracker.cpp
    SOURCES scripthelper.h
    SOURCES scripthelper.cpp
    SOURCES TimerManager.h
    SOURCES TimerManager.cpp
    SOURCES ScreenshotManager.h
    SOURCES ScreenshotManager.cpp
    SOURCES databasehelper.h
    SOURCES databasehelper.cpp

    RESOURCES icons/align.svg
    RESOURCES icons/time.svg
    RESOURCES icons/delete.svg
    RESOURCES icons/analytics.svg
    RESOURCES icons/target.svg
    RESOURCES icons/times.svg
    RESOURCES icons/trend.svg
    RESOURCES icons/play.svg
    RESOURCES icons/pause.svg
    RESOURCES icons/square.svg
    RESOURCES icons/camera.svg
    RESOURCES icons/image.png
    RESOURCES icons/email.svg
    RESOURCES icons/eye.svg
    RESOURCES icons/github.svg
    RESOURCES icons/lock.svg
    RESOURCES icons/microsoft.svg
    RESOURCES icons/logout.svg
    RESOURCES icons/user.png
    RESOURCES icons/pulse.svg

    RESOURCES QML/components/ScreenShot.qml
    RESOURCES QML/components/TimerPanel.qml
    RESOURCES QML/components/TimeLogPanel.qml
    RESOURCES QML/components/TopStatsPanel.qml
    RESOURCES QML/components/BarChartPanel.qml
    RESOURCES QML/components/PieChartPanel.qml
    RESOURCES QML/pages/LoginPage.qml
    RESOURCES QML/pages/Time.qml
    RESOURCES QML/pages/TimeLog.qml
    RESOURCES QML/pages/Analytics.qml
    RESOURCES QML/pages/GoogleLogin.qml
    RESOURCES QML/pages/AzureLogin.qml
    RESOURCES QML/script.js
    RESOURCES QML/Main.qml
    RESOURCES icons/Img.png
    QML_FILES QML/pages/Theme.qml
    RESOURCES QML/pages/qmldir
    RESOURCES icons/google.svg
    RESOURCES icons/pulse.png
    RESOURCES icons/pulse.png
    RESOURCES icons/pulse.png
    RESOURCES icons/appproject-overwatch.png




)
qt_import_qml_plugins(appproject-overwatch)
qt_finalize_executable(appproject-overwatch)


set_target_properties(appproject-overwatch PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appproject-overwatch
    PRIVATE vendor/libuiohook/include
)

target_link_libraries(appproject-overwatch
    PRIVATE  SingleApplication::SingleApplication Qt6::Quick Qt6::Charts Qt6::Sql Qt6::Network uiohook
)

include(GNUInstallDirs)
install(TARGETS appproject-overwatch
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
