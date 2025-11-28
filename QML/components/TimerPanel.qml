import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import projectoverwatch  // Import your C++ QML singleton, adjust version/module as needed
import "../pages"
Rectangle {
    id: timerPanel
    radius: 16
    color: Theme.bg
    border.color: softgray
    border.width: 2

    Column {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 70

        Row {

            Image {
                source: "../../icons/times.svg"
                width: 22
                height: 22
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                smooth: true
            }

            Text {
                // anchors.margins: 26
                text: Theme.timelogtoday
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: Theme.txtcolor
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            // anchors.verticalCenter: parent.verticalCenter
            spacing: 18
            // anchors.centerIn: parent
            Rectangle {
                width:  220      // becomes smaller on small screens, max 220
                  height: 90
                color:Theme.softgrays
                radius: 12
                border.color: Theme.softgray
                border.width: 1
                clip: true

                Text {
                    id: timerText
                    anchors.centerIn: parent
                    text: Theme.timer
                    font.family: "monospace"
                    font.pixelSize: 39
                    color: Theme.text
                }
            }

            // Place this Rectangle exactly where you want the badge to appear (e.g., in your AppBar Row)
            Rectangle {
                width: 140
                height: 32
                radius: 16
                color: Theme.bg  // subtle red background
                opacity: TimerManager.running ? 1 : 0
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    // Blinking indicator
                    Rectangle {
                        id: recordDot
                        width: 12
                        height: 12
                        radius: 6
                        color: "green"
                        anchors.verticalCenter: parent.verticalCenter

                        SequentialAnimation on opacity {
                            running: TimerManager.running
                            loops: Animation.Infinite
                            NumberAnimation { from: 1; to: 0.2; duration: 600 }
                            NumberAnimation { from: 0.2; to: 1; duration: 600 }
                        }
                    }

                    // Recording text
                    Text {
                        text: "Recording..."
                        color: "green"  // strong red
                        font.pixelSize: 16
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // Start/Pause toggle button
                Rectangle {
                    id: startButton
                    width: 80
                    height: 36
                    radius: 8
                    color: TimerManager.running ? Theme.bg : Theme.accent
                    border.color: TimerManager.running ? Theme.accent : "transparent"
                    border.width: 2
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (TimerManager.running)
                                TimerManager.stop()
                            else
                                TimerManager.start()
                        }
                    }
                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            source: TimerManager.running ? "../../icons/pause.svg" : "../../icons/play.svg"
                            width: 16
                            height: 16
                            sourceSize.width: width * Screen.devicePixelRatio
                            sourceSize.height: height * Screen.devicePixelRatio
                            smooth: true
                        }
                        Text {
                            text: TimerManager.running ? "Pause" : "Start"
                            font.pixelSize: 12
                            color: TimerManager.running ? Theme.accent :Theme.bg
                        }
                    }
                }
            }
        }
    }
}
