import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 2.15
import QtQuick.Window
import "script.js" as Script
import "./pages"
import QtCore

ApplicationWindow {

    id: mainWindow
    width: Screen.width
    height: Screen.height
    visible: true

    // title: Qt.application.displayName
    title: tracker.appName === "" ? "project overwatch" : tracker.appName;  // Binds dynamically

    Settings {
        id: appSettings
        property string accessToken: ""
        property string refreshToken: ""
        property string userId: ""
    }
    property bool loggedIn: false
    property var timeLogCache: null
    property var analyticsCache: null
    property var activityCache: null
    property int savedFilterIndex: 0

    property string selectedTab: "Time"
    property string userName:""
    property string userEmail:""
    property int totalSeconds: TimerManager.seconds
    property int hours: Math.floor(totalSeconds / 3600)
    property int minutes: Math.floor((totalSeconds % 3600) / 60)

    property var userLogs: []
    property var logs: []
    property var allLogs: []
    property var activity: []
    property bool showMenu: false

    // ✅ Track AI sync period from C++
    property int aiSyncPeriod: tracker.aiSyncPeriod

    Timer {
        id: aiSyncTimer
        interval: aiSyncPeriod * 60000
        repeat: true
        running: aiSyncPeriod > 0
        onTriggered: {
            console.log("[AI Sync] Running every", aiSyncPeriod, "minutes");
            Script.getUserAnalytics(tracker.getAccessToken, function(data) {
                console.log(JSON.stringify(data),"=========analytics========")
                mainWindow.analyticsCache = data;
                if (pageLoader.item && mainWindow.selectedTab === "Analytics") {
                    pageLoader.item.logs = data;
                }
            });
            Script.getUserTimeLog(tracker.getAccessToken, function(data) {
                data = data;
                mainWindow.timeLogCache = data;
                mainWindow.activityCache = data;
                console.log(JSON.stringify(data),"=======Timelog==========")
                if (pageLoader.item) {
                    if (pageLoader.item.hasOwnProperty("allLogs"))
                        pageLoader.item.allLogs = data.slice();

                    if (pageLoader.item.hasOwnProperty("logs"))
                        pageLoader.item.logs = data.slice();

                    if (pageLoader.item.hasOwnProperty("activity"))
                        pageLoader.item.activity = data.slice();  // will only run if property exists
                }else {
                    // fallback: assign to mainWindow cache, will assign later when loaded
                    mainWindow.timeLogCache = data;
                }
            });
        }
    }

    // Update Timer if C++ changes the period
    onAiSyncPeriodChanged: {
        console.log("[AI Sync] Period updated to", aiSyncPeriod, "minutes");
        aiSyncTimer.interval = aiSyncPeriod * 60000;
        aiSyncTimer.running = aiSyncPeriod > 0;
    }

    Connections {
        target: TimerManager
        onAiSyncRequested: {
            console.log("[AI Sync] Manual trigger requested");
            aiSyncTimer.triggered();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.softgray
        border.width: 1

        // Main Card

        Loader {
            id: loginLoader
            anchors.fill: parent
            visible: !mainWindow.loggedIn
            source: "../QML/pages/LoginPage.qml"
        }

        Rectangle {
            id:mainpage
            width: parent.width
            height: parent.height
            radius: 18
            color: Theme.bg

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter    // center vertically
            anchors.margins: 0
            visible: mainWindow.loggedIn
            // AppBar
            Rectangle {
                width: parent.width - 20
                height: 54
                color: Theme.bg
                radius: 12
                border.width: 1
                border.color: Theme.softgray
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 7
                visible: mainWindow.loggedIn

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 3

                    // ---------- LEFT SECTION ----------
                    RowLayout {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillWidth: true
                        spacing: 8

                        Image {
                            source: "qrc:/project-overwatch/icons/pulse.svg"
                            Layout.preferredHeight: 25
                            Layout.preferredWidth: 25
                            sourceSize.width: width * Screen.devicePixelRatio
                            sourceSize.height: height * Screen.devicePixelRatio
                            smooth: true
                        }

                        Text {
                            text: "Project overwatch"
                            font.bold: true
                            font.pixelSize: 23
                            color: Theme.text
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // ---------- CENTER DATE ----------
                    Text {
                        text: Theme.date
                        font.pixelSize: 14
                        color: Theme.smalltxt

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // ---------- RIGHT USER BUTTON ----------
                    Rectangle {
                        id: userButton
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: 170
                        Layout.preferredHeight: 32
                        radius: 10
                        border.width: 1
                        border.color: Theme.softgray

                        property double lastCloseMs: 0

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: function(mouse) {
                                if (userMenu.visible) {
                                    userMenu.close()
                                    mouse.accepted = true
                                    return
                                }
                                if (Date.now() - userButton.lastCloseMs < 200) {
                                    mouse.accepted = true
                                    return
                                }
                                userMenu.open()
                                mouse.accepted = true
                            }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 4
                            Image {
                                source: "qrc:/project-overwatch/icons/user.png"
                                width: 16; height: 16
                                smooth: true
                            }
                            Text {
                                text: "Welcome, " + mainWindow.userName
                                font.pixelSize: 15
                                color: Theme.txtcolor
                            }
                        }

                        // ---------- FIXED & PERFECT MENU ----------
                        Menu {
                            id: userMenu

                            x: userButton.mapToItem(null, 0, 0).x
                            y: userButton.mapToItem(null, 0, userButton.height).y -13
                            width: userButton.width

                            closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
                            modal: false
                            focus: true

                            onClosed: userButton.lastCloseMs = Date.now()

                            background: Rectangle {
                                radius: 8
                                border.width: 1
                                border.color: "#E0E0E0"
                                color: Theme.bg
                                anchors.fill: parent
                                anchors.margins: 6   // FIX: padding for full menu
                            }

                            MenuItem {
                                id: logout
                                text: "Logout"
                                height: 36
                                leftPadding: 14
                                rightPadding: 14

                                contentItem: Text {
                                    text: parent.text
                                    anchors.centerIn: parent
                                    font.pixelSize: 15
                                    color: "black"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                }

                                background: Rectangle {
                                    radius: 6
                                    color: logout.hovered ? Theme.colorBlue : Theme.bg
                                    anchors.fill: parent
                                    anchors.margins: 4   // FIX: prevent bottom touching
                                }

                                onTriggered: {

                                    globalLoader.showLoader();
                                    mainWindow.analyticsCache = null
                                    mainWindow.activityCache = null
                                    mainWindow.timeLogCache = null
                                    mainWindow.userEmail = ""
                                    Script.logout(tracker.getAccessToken)
                                }
                            }
                        }
                    }
                }
            }


            // Tabbar
            Rectangle {
                id: tabBar
                width: parent.width-20
                height: 40
                visible: mainWindow.loggedIn
                anchors.top: parent.top
                anchors.topMargin: 70
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.softgrays
                radius: 25


                Row {
                    id: tabRow
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10

                    Rectangle {
                        width: (tabBar.width - (2 * 10) - 2 * tabRow.anchors.margins) / 3 // Set your preferred width
                        height: 30  // Set your preferred height
                        radius: 20
                        color: mainWindow.selectedTab === "Time" ? Theme.bg : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mainWindow.selectedTab = "Time"
                                pageLoader.source = "../QML/pages/Time.qml"
                            }
                        }
                        Row {
                            anchors.centerIn: parent
                            Image {
                                source: "qrc:/project-overwatch/icons/times.svg"
                                width: 22
                                height: 20
                                sourceSize.width: width * Screen.devicePixelRatio
                                sourceSize.height: height * Screen.devicePixelRatio
                                smooth: true
                            }
                            Text {
                                text: "Timer"
                                color: Theme.primary
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        width: (tabBar.width - (2 * 10) - 2 * tabRow.anchors.margins) / 3   // Set your preferred width
                        height: 30  // Set your preferred height
                        radius: 20

                        color: mainWindow.selectedTab === "TimeLog" ? Theme.bg : "transparent"


                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mainWindow.selectedTab = "TimeLog"
                                pageLoader.source = "../QML/pages/TimeLog.qml"

                                // ✅ Check if cached
                                if (mainWindow.timeLogCache) {
                                    console.log("Using cached TimeLog data");
                                    if (pageLoader.item) {
                                        pageLoader.item.logs = mainWindow.timeLogCache
                                        pageLoader.item.allLogs = mainWindow.timeLogCache
                                    }
                                } else {
                                    globalLoader.showLoader();
                                    Script.getUserTimeLog(tracker.getAccessToken, function(data) {

                                        mainWindow.timeLogCache = data  // ✅ Save to cache
                                        if (pageLoader.item) {
                                            pageLoader.item.logs = data.slice();
                                            pageLoader.item.allLogs = data.slice();
                                        }
                                    })
                                }
                            }
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing:5
                            Image {
                                source: "qrc:/project-overwatch/icons/align.svg"
                                width: 18
                                height: 18
                                sourceSize.width: width * Screen.devicePixelRatio
                                sourceSize.height: height * Screen.devicePixelRatio
                                smooth: true
                            }
                            Text {
                                text: "Time Log"
                                color: Theme.primary
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                    Rectangle {
                        width: (tabBar.width - (2 * 10) - 2 * tabRow.anchors.margins) / 3   // Set your preferred width
                        height: 30  // Set your preferred height
                        radius: 20
                        color: mainWindow.selectedTab === "Analytics" ? Theme.bg : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mainWindow.selectedTab = "Analytics"
                                pageLoader.source = "../QML/pages/Analytics.qml"
                                if (mainWindow.analyticsCache) {
                                    console.log("Using cached Analytics data");
                                    if (pageLoader.item) {
                                        pageLoader.item.logs = mainWindow.analyticsCache
                                    }
                                } else {
                                    globalLoader.showLoader();
                                    Script.getUserAnalytics(tracker.getAccessToken, function(data) {
                                          // console.log(JSON.stringify(data),"=======Timelog==========")
                                        mainWindow.analyticsCache = data; // ✅ Save to cache

                                        if (pageLoader.item) {
                                            pageLoader.item.logs = data
                                        }
                                    });
                                }
                                if (mainWindow.activityCache) {
                                    console.log("Using cached Activity data");
                                    if (pageLoader.item) {
                                        pageLoader.item.activity = mainWindow.activityCache
                                    }
                                } else {
                                    Script.getUserTimeLog(tracker.getAccessToken, function(data) {

                                        mainWindow.activityCache = data; // ✅ Save to cache
                                        if (pageLoader.item) {
                                            pageLoader.item.activity = data
                                        }
                                    });
                                }
                            }
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing:10
                            Image {
                                source: "qrc:/project-overwatch/icons/analytics.svg"
                                width: 16
                                height: 16
                                sourceSize.width: width * Screen.devicePixelRatio
                                sourceSize.height: height * Screen.devicePixelRatio
                                smooth: true
                            }
                            Text {
                                text: "Analytics"
                                color: Theme.primary
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }
            }
            Loader {
                id: pageLoader
                anchors.top: tabBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                source: "../QML/pages/Time.qml"
            }
        }
    }

    Rectangle {
        id: globalLoader
        anchors.fill: parent
        color: Theme.loaderrectanglecolor
        visible: running
        z: 1000
        opacity: running ? 1 : 0

        property bool running: false
        property bool minTimePassed: false
        property bool requestedHide: false

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Timer {
            id: minTimer
            interval: 1000
            running: false
            repeat: false
            onTriggered: {
                globalLoader.minTimePassed = true
                if (globalLoader.requestedHide) {
                    globalLoader.running = false
                    globalLoader.requestedHide = false
                }
            }
        }

        function showLoader() {
            globalLoader.running = true
            globalLoader.minTimePassed = false
            globalLoader.requestedHide = false
            minTimer.start()
        }

        function hideLoader() {
            if (globalLoader.minTimePassed) {
                globalLoader.running = false
            } else {
                globalLoader.requestedHide = true
            }
        }

        // Center spinning loader
        Item {
            width: 110
            height: 110
            anchors.centerIn: parent

            Canvas {
                id: loaderCanvas
                anchors.fill: parent
                property real rotation: 0

                onPaint: {
                    var ctx = getContext("2d");
                    var dpr = Screen.devicePixelRatio || 1;

                    // Make canvas high resolution
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);

                    var w = width * dpr;
                    var h = height * dpr;
                    ctx.scale(dpr, dpr);

                    var centerX = Math.round(width / 2);
                    var centerY = Math.round(height / 2);
                    var radius = 30;

                    // Background circle
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
                    ctx.lineWidth = 4;
                    ctx.strokeStyle = Theme.softgray
                    ctx.stroke();

                    // Spinning arc
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, rotation, rotation + Math.PI * 1.5, false);
                    ctx.lineWidth = 4;
                    var gradient = ctx.createLinearGradient(0, 0, width, height);
                    gradient.addColorStop(0, Theme.accent);           // start color
                    gradient.addColorStop(1, Theme.loadergradientcolor); // lighter blue end for smooth gradient
                    ctx.strokeStyle = gradient;

                    ctx.shadowBlur = 1;
                    ctx.shadowColor = Theme.accent;
                    ctx.stroke();
                }

                Timer {
                    interval: 16
                    repeat: true
                    running: globalLoader.running
                    onTriggered: {
                        loaderCanvas.rotation += Math.PI / 45;
                        if (loaderCanvas.rotation >= Math.PI * 2)
                            loaderCanvas.rotation = 0;
                        loaderCanvas.requestPaint();
                    }
                }
            }

            Text {
                text: "Loading..."
                anchors.top: loaderCanvas.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 14
                color: "black"
                anchors.topMargin: 6
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}   // block clicks behind loader
        }
    }
    Rectangle {
        id: toast
        width: parent.width * 0.6
        height: 40
        radius: 8
        color: Theme.danger // error color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        opacity: 0
        visible: false

        Text {
            anchors.centerIn: parent
            color: Theme.bg
            text: toast.message
            font.pixelSize: 16
        }

        property string message: ""

        function show(message) {
            toast.message = message
            toast.opacity = 1
            toast.visible = true
            toastTimer.start()
        }

        Timer {
            id: toastTimer
            interval: 2000
            repeat: false
            onTriggered: {
                toast.opacity = 0
                toast.visible = false
            }
        }
    }

    Component.onCompleted: {

        if (appSettings.accessToken !== "") {

            loggedIn = true;
            // token exists, restore session
            tracker.setAccessToken(appSettings.accessToken);
            Script.fetchUserProfile(appSettings.accessToken);
            tracker.fetchData(appSettings.accessToken);
            loggedIn = true;
            pageLoader.source = "./pages/Time.qml";  // directly open time page
        } else {
            loggedIn = false;
            pageLoader.source = "./pages/LoginPage.qml";
        }
    }
}

