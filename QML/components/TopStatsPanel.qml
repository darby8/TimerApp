// TopStatsPanel.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../pages"
Row {
    property int totalSeconds: TimerManager.seconds
    property int hours: Math.floor(totalSeconds / 3600)
    property int minutes: Math.floor((totalSeconds % 3600) / 60)
    property string todayText: "Today total: " + hours + "h " + minutes + "m"
    property string tasksCount: "2"
    property string avgPerDay: "12m"

    property color boxColor: Theme.bg

    anchors.margins: 20
    spacing: 15

    Rectangle {
        width: (statsRow.width - 2 * statsRow.spacing) / 3
        height: 80
        radius: 8
        color: boxColor
        border.color: Theme.borders
        Row {
            anchors.centerIn: parent
            Image {
                source: "../../icons/time.svg"
                width: 25
                height: 25
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                spacing: 2
                Text { text: "Today"; color: Theme.smalltxt;font.pointSize: 10 }
                Text { text: todayText; color: Theme.boldText; font.pointSize: 16; font.bold: true }
            }
        }
    }
    Rectangle {
        width: (statsRow.width - 2 * statsRow.spacing) / 3
        height: 80
        radius: 8
        color: boxColor
        border.color:Theme.borders
        Row {
            anchors.centerIn: parent
            spacing: 8
            Image {
                source: "../../icons/target.svg"
                width: 18
                height: 18
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                spacing: 2
                Text { text: "Tasks"; color: Theme.smalltxt; font.pointSize: 10 }
                Text { text: tasksCount; color: Theme.boldText; font.pointSize: 16; font.bold: true }
            }
        }
    }
    Rectangle {
        width: (statsRow.width - 2 * statsRow.spacing) / 3
        height: 80
        radius: 8
        color: boxColor
        border.color:Theme.borders
        Row {
            anchors.centerIn: parent
            spacing: 8
            Image {
                source: "../../icons/trend.svg"
                width: 20
                height: 20
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                smooth: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                spacing: 2
                Text { text: "Avg/Day"; color: Theme.smalltxt; font.pointSize: 10 }
                Text { text: avgPerDay; color:  Theme.boldText; font.pointSize: 16; font.bold: true }
            }
        }
    }
}
