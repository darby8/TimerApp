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
            Layout.preferredWidth: parent.width * 0.50
            Layout.preferredHeight: parent.height
            color: Theme.bg
            border.color: Theme.softgray
            // danger: danger

        }


        // Task Manager
        ScreenShot {
            Layout.preferredWidth: parent.width * 0.50
            Layout.preferredHeight: parent.height
            color: Theme.bg
            border.color: Theme.softgray
        }
    }
}

