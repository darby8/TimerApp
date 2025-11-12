// PieChartPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCharts
import "../pages"

Rectangle {
    property var activity: []   // ✅ Holds raw activity data
    width: 550; height: 330
    color: Theme.bg
    radius: 8
    border.color: Theme.borders

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        Text {
            text: Theme.category
            font.pointSize: 12
            font.bold: true
        }

        ChartView {
            id: chartView
            width: parent.width+70; height: 400
            legend.visible: true
            legend.alignment: Qt.AlignRight   // ✅ Legend on right sides
            legend.labelColor: "black"        // ✅ Make sure text is readable
            legend.font.pointSize: 10       // ✅ Slightly smaller font so full text fits
            // legend.attachToChart: false   // <✅ Detach legend so we can position manually
            legend.x: chartView.width - legend.width - 100  // <✅ Move 40px away from right
            legend.y: chartView.height / 2 - legend.height / 2
            antialiasing: true
            backgroundRoundness: 0
            Layout.alignment: Qt.AlignHCenter
            layer.enabled: true
            layer.smooth: true
            layer.mipmap: false

            PieSeries {
                id: singlePie
                horizontalPosition: 0.35
                verticalPosition: 0.5
            }
        }
    }



    onActivityChanged: {
        updatePieChart(1, 0);  // default: Today
    }
    function parseDate(dateString) {
        return new Date(dateString);
    }

    // ---------------------------
    // Function to update based on range
    function updatePieChart(rangeDays, offsetDays) {
        singlePie.clear();

        if (!activity || activity.length === 0)
            return;

        let today = new Date();
        today.setHours(0, 0, 0, 0);

        let endDate = new Date(today);
        endDate.setDate(today.getDate() - (offsetDays || 0));

        let startDate = new Date(endDate);
        startDate.setDate(endDate.getDate() - (rangeDays - 1));

        let filtered = activity.filter(a => {
            let start = parseDate(a.start_time);
            start.setHours(0, 0, 0, 0);
            return start >= startDate && start <= endDate;
        });

        if (filtered.length === 0)
            return;

        // Group by category_of_work
        let totals = {};
        let totalMinutes = 0;

        for (let i = 0; i < filtered.length; i++) {
            let cat = filtered[i].category_of_work || "Unknown";
            if (!totals[cat]) totals[cat] = 0;
            totals[cat] += filtered[i].estimation_of_time_worked_in_mins;
            totalMinutes += filtered[i].estimation_of_time_worked_in_mins;
        }

        // property color colorOrange: "#FFA500"
        // property color colorPink:   "#EF5DA8"
        // property color colorTeal:   "#45B8AC"
        // property color colorBrown:  "#8D5524"
        // property color colorCyan:   "#00BFAE"
        // property color colorNavy:   "#205375"
        // property color colorGray:   "#7D7F7D"
        // property color colorBeige:  "#FFF3CD"





        let colors = [Theme.colorBlue, Theme.colorRed, Theme.colorGreen, Theme.colorYellow, Theme.colorPurple, Theme.colorOrange, Theme.colorPink, Theme.colorTeal, Theme.colorBeige, Theme.colorBrown,
                      Theme.colorCyan, Theme.colorNavy, Theme.colorGray
            ];
        let colorIndex = 0;

        for (let cat in totals) {
            let minutes = totals[cat];
            singlePie.append(cat, minutes);

            let slice = singlePie.at(singlePie.count - 1);
            slice.color = colors[colorIndex % colors.length];
            slice.label = `${cat}: ${(minutes / 60).toFixed(1)}h`;
            slice.labelVisible = false;

            slice.labelPosition = PieSlice.LabelOutside;
            slice.labelColor = "black";
            slice.borderColor = Theme.bg;
            slice.borderWidth = 2;

            colorIndex++;
        }
    }

}
