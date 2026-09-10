import QtQuick
import QtQuick.Layouts
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "clock"
    edge: "center"

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    property int viewYear: now.getFullYear()
    property int viewMonth: now.getMonth() // 0-based, month being displayed (can differ from `now` via nav)

    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate(); }
    function firstWeekdayMon0(y, m) { return (new Date(y, m, 1).getDay() + 6) % 7; } // Monday = 0

    readonly property var calendarWeeks: {
        const weeks = [];
        const total = root.daysInMonth(root.viewYear, root.viewMonth);
        const lead = root.firstWeekdayMon0(root.viewYear, root.viewMonth);
        let week = new Array(lead).fill(0);
        for (let d = 1; d <= total; d++) {
            week.push(d);
            if (week.length === 7) { weeks.push(week); week = []; }
        }
        if (week.length > 0) { while (week.length < 7) week.push(0); weeks.push(week); }
        return weeks;
    }

    readonly property real dayFraction: {
        const mins = now.getHours() * 60 + now.getMinutes();
        return Math.max(0, Math.min(1, mins / (24 * 60)));
    }

    PanelCard {
        width: 620
        headerGlyph: Icons.clock
        statusColor: Theme.color.sand

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.lg

            // --- LEFT: calendar ---
            ColumnLayout {
                Layout.preferredWidth: 190
                spacing: Theme.gap.sm

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: Icons.caretLeft
                        font.family: Theme.font.icon
                        font.pixelSize: 11
                        color: Theme.color.fgDim
                        Ripple {
                            anchors.margins: -6
                            cornerRadius: height / 2
                            onClicked: {
                                root.viewMonth--;
                                if (root.viewMonth < 0) { root.viewMonth = 11; root.viewYear--; }
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.locale().monthName(root.viewMonth).toUpperCase()
                        color: Theme.color.fgBright
                        font.family: Theme.font.sans
                        font.pixelSize: Theme.font.sizeUi
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: Icons.caretRight
                        font.family: Theme.font.icon
                        font.pixelSize: 11
                        color: Theme.color.fgDim
                        Ripple {
                            anchors.margins: -6
                            cornerRadius: height / 2
                            onClicked: {
                                root.viewMonth++;
                                if (root.viewMonth > 11) { root.viewMonth = 0; root.viewYear++; }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        delegate: Text {
                            required property string modelData
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: Theme.color.teal
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi - 3
                        }
                    }
                }

                Repeater {
                    model: root.calendarWeeks
                    delegate: RowLayout {
                        id: weekRow
                        required property var modelData
                        Layout.fillWidth: true
                        Repeater {
                            model: weekRow.modelData
                            delegate: Rectangle {
                                required property int modelData
                                readonly property bool isToday: modelData > 0
                                    && modelData === root.now.getDate()
                                    && root.viewMonth === root.now.getMonth()
                                    && root.viewYear === root.now.getFullYear()
                                Layout.fillWidth: true
                                implicitHeight: 24
                                radius: 12
                                color: isToday ? Theme.color.accent : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData > 0 ? modelData : ""
                                    color: isToday ? Theme.color.fgBright : Theme.color.fg
                                    font.family: Theme.font.mono
                                    font.pixelSize: Theme.font.sizeUi - 2
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: Theme.color.surface }

            // --- CENTRE: sun-arc + time ---
            ColumnLayout {
                Layout.preferredWidth: 190
                spacing: 0

                RingGauge {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.gap.sm
                    width: 170
                    height: 90
                    startAngle: 180
                    sweepAngle: 180
                    value: root.dayFraction
                    tint: "transparent"
                    track: Theme.color.surface

                    Text {
                        x: parent.width * root.dayFraction - width / 2
                        y: parent.height - (Math.sin(Math.PI * root.dayFraction) * (parent.height - 10)) - height
                        text: Icons.sun
                        font.family: Theme.font.icon
                        font.pixelSize: 14
                        color: Theme.color.sand
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(root.now, "hh:mm")
                    color: Theme.color.fgBright
                    font.family: Theme.font.sans
                    font.pixelSize: 34
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.now, "dddd, d MMMM")
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 1
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.gap.sm
                    spacing: Theme.gap.md
                    Row {
                        spacing: 4
                        Text { text: Icons.sun; font.family: Theme.font.icon; font.pixelSize: 11; color: Theme.color.sand }
                        Text { text: WeatherStore.sunrise; font.family: Theme.font.mono; font.pixelSize: Theme.font.sizeUi - 3; color: Theme.color.fgDim }
                    }
                    Row {
                        spacing: 4
                        Text { text: Icons.moon; font.family: Theme.font.icon; font.pixelSize: 11; color: Theme.color.maroon }
                        Text { text: WeatherStore.sunset; font.family: Theme.font.mono; font.pixelSize: Theme.font.sizeUi - 3; color: Theme.color.fgDim }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: Theme.color.surface }

            // --- RIGHT: weather ---
            ColumnLayout {
                Layout.preferredWidth: 140
                spacing: Theme.gap.xs

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: WeatherStore.tempC + "°"
                    color: Theme.color.fgBright
                    font.family: Theme.font.sans
                    font.pixelSize: 32
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: WeatherStore.condition
                    color: Theme.color.teal
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 1
                }

                Item { Layout.preferredHeight: Theme.gap.md }

                IconRow {
                    Layout.fillWidth: true
                    glyph: Icons.wind
                    tint: Theme.color.teal
                    label: "Wind"
                    value: WeatherStore.windKmph + " km/h"
                }
                IconRow {
                    Layout.fillWidth: true
                    glyph: Icons.tint
                    tint: Theme.color.teal
                    label: "Humidity"
                    value: WeatherStore.humidity + "%"
                }
            }
        }
    }
}
