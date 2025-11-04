import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
Item {
    id: timerLog
    property var logs: []
    property var allLogs: []

    TimeLogPanel {
        id: timeLogPanel

            totalTimeText: "Today total: " + hours + "h " + minutes + "m"
            logs: timerLog.logs
            allLogs:  timerLog.allLogs
        }
}




