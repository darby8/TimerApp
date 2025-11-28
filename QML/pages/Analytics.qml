import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtCharts
import Qt.labs.settings 1.1
import "../components"
Item {
    id: analytics
    property var activity: []
    property var logs: []

    Rectangle {
        width: parent.width
        id: headerSection
        // anchors.fill: parent
        z:1000
        color: Theme.bg
        ColumnLayout {
            id: statsRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.fill: parent
            anchors.margins: 10
            spacing: 16

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
                Settings {
                    id: filterSettings
                    property int savedFilterIndexA: 0     // default Today
                }

                ComboBox {
                    id: dateFilter
                    model: ["Today", "Yesterday", "Last 7 days", "Last 30 days"]
                    width: 160
                    Component.onCompleted: {
                            Qt.callLater(function() {
                                currentIndex = filterSettings.savedFilterIndexA
                                applyFilter()
                            })
                        }

                    onCurrentIndexChanged: {
                           filterSettings.savedFilterIndexA = currentIndex   // save permanently
                           applyFilter()
                       }
                    function applyFilter() {
                        switch(currentIndex) {
                        case 0:
                            barChart.titleText = "Daily Activity (Today)";
                            barChart.updateChart(1, 0);
                            pieChart.updatePieChart(1, 0);   // ✅ added
                            break;
                        case 1:
                            barChart.titleText = "Daily Activity (Yesterday)";
                            barChart.updateChart(1, 1);
                            pieChart.updatePieChart(1, 1);   // ✅ added
                            break;
                        case 2:
                            barChart.titleText = "Daily Activity (Last 7 Days)";
                            barChart.updateChart(7, 0);
                            pieChart.updatePieChart(7, 0);   // ✅ added
                            break;
                        case 3:
                            barChart.titleText = "Daily Activity (Last 30 Days)";
                            barChart.updateChart(30, 0);
                            pieChart.updatePieChart(30, 0);  // ✅ added
                            break;
                        }
                    }
                }
            }
            TopStatsPanel {
                Layout.fillWidth: true
                todayText: "" + hours + "h " + minutes + "m"
                tasksCount:  barChart.task
                avgPerDay: barChart.avgHours.toFixed(1) + "h"
            }
        }

    }
    RowLayout {
         anchors.top: headerSection.bottom
         anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.margins: 17
          anchors.rightMargin: 17
          spacing: 12
          anchors.topMargin: 150



        // Bar Chart
        BarChartPanel {
            id: barChart
            Layout.preferredWidth: parent.width * 0.50
            Layout.preferredHeight: parent.height
            color: Theme.bg
            border.color: Theme.softgray
            logs: analytics.logs
        }


        // Pie Chart
        PieChartPanel {
            id:pieChart
            activity:analytics.activity
            Layout.preferredWidth: parent.width * 0.50
            Layout.preferredHeight: parent.height
            color: Theme.bg
            border.color: Theme.softgray
        }
    }
}

