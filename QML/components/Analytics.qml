import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtCharts
Item {

    Rectangle {
        width: parent.width - 20
        // anchors.fill: parent
        color: "#f6f7fb"
        ColumnLayout {
            id: statsRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            // Top Stats
            TopStatsPanel {
                Layout.fillWidth: true
                todayText: "" + hours + "h " + minutes + "m"
                tasksCount: "2"
                avgPerDay: "12m"
            }


            // Graphs section
            RowLayout {
                spacing: 16
                // Bar Chart
                BarChartPanel { }


                // Pie Chart
                PieChartPanel { }
            }
        }
    }
}
