import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../script.js" as Script
import "../pages"
Rectangle {
    id: root
    width: parent.width * 0.95
    height: parent.height*0.92
    radius: 8
    color: Theme.bg
    border.width: 2
    border.color: Theme.borders

    property alias totalTimeText: totalTime.text
    property var logs: []
    property var allLogs: []
    property bool filterApplied: false

    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: 32

    ColumnLayout {
        id: statsRow
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        RowLayout {
            width: parent.width
            Layout.alignment: Qt.AlignTop

            // Left section (Time Log + total)
            ColumnLayout {
                spacing: 2
                Row {
                    spacing: 4
                    Image {
                        source: "../../icons/times.svg"
                        width: 20; height: 20
                        sourceSize.width: width * Screen.devicePixelRatio
                        sourceSize.height: height * Screen.devicePixelRatio
                        smooth: true
                    }
                    Text {
                        text: "Time Log"
                        font.pixelSize: 18
                        color: Theme.txtcolor
                    }
                }

                Text {
                    id: totalTime
                    text: "Today total: --h --m"
                    color: Theme.timetxt
                    font.pixelSize: 14
                }
            }

            Item { Layout.fillWidth: true }

            // Right section (Filter)
            Row {
                spacing: 8
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 12

                Text {
                    text: "Filter:"
                    font.pixelSize: 14
                    color: Theme.smalltxt;
                    anchors.verticalCenter: parent.verticalCenter
                }

                ComboBox {
                    id: dateFilter
                    model: ["Today", "Yesterday", "Last 7 days", "Last 30 days"]
                    width: 160
                    currentIndex: 0

                    onCurrentIndexChanged: applyFilter()

                    Component.onCompleted: {
                        applyFilter();  // ✅ Run once when component is created
                    }

                    function applyFilter() {
                        switch(currentIndex) {
                        case 0:
                            timeLogPanel.logs = filterLogs(timeLogPanel.allLogs, 1, 0);  // Today
                            break;
                        case 1:
                            timeLogPanel.logs = filterLogs(timeLogPanel.allLogs, 1, 1);  // Yesterday
                            break;
                        case 2:
                            timeLogPanel.logs = filterLogs(timeLogPanel.allLogs, 7, 0);  // Last 7 days
                            break;
                        case 3:
                            timeLogPanel.logs = filterLogs(timeLogPanel.allLogs, 30, 0); // Last 30 days
                            break;
                        }
                    }
                }

            }
        }

        // Dynamic list of logs
        ListView {
            id: logList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            clip: true
            // model: logs
            model: timeLogPanel.logs
            delegate: Rectangle {
                width: logList.width
                color: Theme.softgrays
                radius: 8
                border.color: Theme.softgray
                border.width: 1
                Layout.fillWidth: true
                height: 60

                RowLayout {
                    spacing: 16
                    anchors.fill: parent
                    anchors.margins: 10

                    // Colored dot
                    Rectangle {
                        width: 10; height: 10
                        color: Theme.colorBlue
                        radius: 5
                    }

                    // Intent and time
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: modelData.intent
                            font.bold: true
                        }
                        Text {
                            text: modelData.start_time
                                  ? Qt.formatDateTime(new Date(modelData.start_time), "hh:mm ap")
                                    + " • " + Script.formatMinutesToHoursMins(modelData.estimation_of_time_worked_in_mins)
                                  : ""
                            color: Theme.timetxt
                            font.pixelSize: 13
                        }

                    }

                    Item { Layout.fillWidth: true }

                    // Category
                    Rectangle {
                        width: 150
                        height: 27
                        radius: 5
                        border.width: 1
                        border.color: Theme.borders
                        color: Theme.softgray

                        Text {
                            text: modelData.category_of_work
                            font.pixelSize: 12
                            color: Theme.txtcolor
                            anchors.centerIn: parent
                        }
                    }

                    // Delete icon
                    Row {
                        spacing: 10

                        MouseArea {
                            width: 20
                            height: 20
                            onClicked: {
                                // console.log("Delete icon clicked for index:", index, "id:", modelData.id);
                                Script.deleteProductivityById(tracker.getAccessToken, modelData.id, function(success) {
                                    if (success) {
                                        logs.splice(index, 1)
                                        logs = logs// remove from QML ListModel only if delete succeeded
                                    }
                                });
                            }

                            Image {
                                anchors.centerIn: parent
                                source: "../../icons/delete.svg"
                                width: parent.width
                                height: parent.height
                                sourceSize.width: width * Screen.devicePixelRatio
                                sourceSize.height: height * Screen.devicePixelRatio
                                smooth: true
                            }
                        }

                    }
                }
            }
        }
    }

    // Compute total time whenever logs change
    onLogsChanged: {

        var total = 0;
        for (var i = 0; i < logs.length; i++) {
            total += logs[i].estimation_of_time_worked_in_mins || 0;
        }
        var h = Math.floor(total / 60);
        var m = total % 60;
        totalTime.text = "Today total: " + h + "h " + m + "m";
    }
    function filterLogs(logsArray, rangeDays, offsetDays) {
        if (!logsArray || logsArray.length === 0) return []; // safety check

        let today = new Date();
        today.setHours(0, 0, 0, 0);

        let endDate = new Date(today);
        endDate.setDate(today.getDate() - (offsetDays || 0));

        let startDate = new Date(endDate);
        startDate.setDate(endDate.getDate() - (rangeDays - 1));

        return logsArray.filter(function(l) {
            if (!l.start_time) return false;
            let d = new Date(l.start_time);
            d.setHours(0, 0, 0, 0);
            return d >= startDate && d <= endDate;
        });
    }



    onAllLogsChanged: {
        if (!filterApplied && allLogs.length > 0) {
            dateFilter.currentIndex = 0;  // ✅ select Today
            dateFilter.applyFilter();     // ✅ filter for today
            filterApplied = true;         // ✅ prevent re-filtering on future updates
        }
    }
}
