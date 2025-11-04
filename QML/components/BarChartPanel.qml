// BarChartPanel.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import "../pages"
Rectangle {
    width: 550; height: 330
    color: Theme.bg
    radius: 8
    border.color: Theme.borders
    antialiasing: true           // enable AA globally again
    property var logs: []
    property int task: 0

    property real avgHours: 0
    Layout.alignment: Qt.AlignHCenter
    layer.enabled: true
    layer.smooth: true           // ensure chart itself is rendered smoothly
    layer.mipmap: false
    property string titleText: "Daily Activity"
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        Text { text: titleText; font.pointSize: 12; font.bold: true }
        ChartView {
            width: parent.width+70; height: 400
            legend.visible: true
            antialiasing: false
            BarCategoryAxis {
                id: daysAxis
                categories: []
                labelsFont.family: "Arial"
                labelsFont.pointSize: 11
                labelsColor: "black"
                // labelsAngle: rangeDays > 7 ? -45 : 0
            }
            ValueAxis {
                id: valueAxis
                min: 0
                max: 9
                tickCount: 10
                labelFormat: "%d"
            }
            BarSeries {
                id: barSeries
                axisX: daysAxis
                axisY: valueAxis
                BarSet {
                    id: barSet
                    label: "Activity"
                    values: []
                }
            }
        }
    }



    function parseDateLocal(dateString) {
        let parts = dateString.split("-");
        return new Date(parts[0], parts[1] - 1, parts[2]); // year, monthIndex, day
    }
    function mapLogsToChartData(logs, rangeDays, offsetDays) {
        let today = new Date();
        today.setHours(0, 0, 0, 0);

        // Calculate end & start dates
        let endDate = new Date(today);
        endDate.setDate(today.getDate() - (offsetDays || 0));

        let startDate = new Date(endDate);
        startDate.setDate(endDate.getDate() - (rangeDays - 1));

        // Filter logs only within date range
        let filteredLogs = logs.filter(l => {
            let d = parseDateLocal(l.date);
            d.setHours(0, 0, 0, 0);
            return d >= startDate && d <= endDate;
        });

        let totals = {};
        let totalMinutes = 0;
        let totalTasks = 0;  // ✅ sum tasks here

        for (let i = 0; i < filteredLogs.length; i++) {
            let key = filteredLogs[i].date;
            if (!totals[key]) totals[key] = 0;
            totals[key] += filteredLogs[i].minutes;

            totalMinutes += filteredLogs[i].minutes;
            totalTasks += filteredLogs[i].total_tasks;  // ✅ accumulate tasks
        }

        let sortedKeys = Object.keys(totals).sort();

        let categories = [];
        let values = [];
        let step = sortedKeys.length > 7 ? Math.ceil(sortedKeys.length / 15) : 1;

        sortedKeys.forEach((dateKey, index) => {
            let dateParts = dateKey.split("-");
            let dateObj = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);
            values.push(totals[dateKey] / 60.0);

            if (index % step === 0) {
                categories.push(Qt.formatDate(dateObj, "dd MMM"));
            } else {
                categories.push("");
            }
        });

        let avg = sortedKeys.length > 0
            ? (totalMinutes / 60.0) / sortedKeys.length
            : 0;

        return {
            categories: categories,
            values: values,
            avg: avg,
            totalTasks: totalTasks  // ✅ return total tasks
        };
    }


    function updateChart(rangeDays, offsetDays) {
        let mapped = mapLogsToChartData(logs, rangeDays, offsetDays);

        daysAxis.clear();
        daysAxis.categories = mapped.categories;

        daysAxis.labelsFont.pointSize = rangeDays > 7 ? 7 : 8;
        daysAxis.labelsAngle = rangeDays > 7 ? -90 : 0;

        barSet.values = mapped.values;

        let maxValue = mapped.values.length > 0 ? Math.max.apply(null, mapped.values) : 1;
        valueAxis.max = Math.ceil(maxValue + 1);

        avgHours = mapped.avg;
        task = mapped.totalTasks;  // ✅ set your property here
    }

    onLogsChanged: {
          barChart.updateChart(1, 0);  // default: Today
     }

}
