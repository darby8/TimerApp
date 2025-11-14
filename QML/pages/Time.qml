import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"
import "../script.js" as Script
// import projectoverwatch


Item {
    id: time
    property int elapsedSeconds: 0
    property bool running: false
    property bool paused: false

    ListModel {
        id: tasksModel
    }
    // Layout filling the parent
    RowLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 32

        // Timer Panel
        TimerPanel {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Theme.bg
            border.color: Theme.softgray
            // danger: danger

        }


        // Task Manager
        ScreenShot {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Theme.bg
            border.color: Theme.softgray
        }
    }
}

