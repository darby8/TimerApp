import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
Item {
    id: timerLog
    property var logs: []
    property var allLogs: []
    property var activity: []
    property int savedFilterIndex: 0
    TimeLogPanel {
        id: timeLogPanel

            totalTimeText: "Today total: " + hours + "h " + minutes + "m"
            logs: timerLog.logs
            allLogs:  timerLog.allLogs
        }
}




