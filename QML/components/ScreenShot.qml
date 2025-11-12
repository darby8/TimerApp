import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../pages"

Rectangle {
    radius: 16
    color: Theme.bg
    border.color: softgray
    border.width: 2

    Column {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 16

        Row {
            spacing: 4
            Image {
                source: "../../icons/camera.svg"
                width: 22
                height: 22
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                smooth: true
            }
            Text {
                text: Theme.lastscreenshot
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: Theme.txtcolor
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height * 0.92
            radius: 50
            color: Theme.softgrays
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 0
                source: ScreenshotManager.lastScreenshotPath !== "" ? ScreenshotManager.lastScreenshotPath : "../../icons/Img.png"
                onStatusChanged: {
                        if (status === Image.Error) {
                            source = "../../icons/Img.png"
                        }
                    }
                // fillMode: Image.PreserveAspectCrop
            }

            // Time overlay bottom right
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 15
                color: Theme.softgray
                radius: 6
                opacity: 0.7
                width: 65
                height: 22

                Text {
                    anchors.centerIn: parent
                    text: tracker.lastCaptureTime && tracker.lastCaptureTime !== ""
                    ?  tracker.lastCaptureTime: "00:00"
                    color: Theme.boldText
                    font.pixelSize: 12
                }
            }
        }
    }
}

