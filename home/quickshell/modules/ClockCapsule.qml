import QtQuick
import QtQuick.Layouts
import ".."

// Centre pill: clock + weather. Opens the Clock dashboard (calendar,
// sun-arc, wind/humidity).
Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property string timeText: Qt.formatTime(new Date(), "hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.timeText = Qt.formatTime(new Date(), "hh:mm")
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.gap.sm

        Text {
            text: root.timeText
            color: Theme.color.fg
            font.family: Theme.font.sans
            font.pixelSize: Theme.font.sizeBar + 1
            font.weight: Font.Medium
        }

        Rectangle {
            implicitWidth: weatherRow.implicitWidth + Theme.gap.md * 2
            implicitHeight: 30
            radius: 15
            color: Theme.color.bgAlt
            border.width: 1
            border.color: Theme.color.surface

            RowLayout {
                id: weatherRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: Icons.cloud
                    font.family: Theme.font.icon
                    font.pixelSize: 14
                    color: Theme.color.sand
                }
                Text {
                    text: WeatherStore.tempC + "°"
                    color: Theme.color.fg
                    font.family: Theme.font.mono
                    font.pixelSize: Theme.font.sizeUi
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelState.toggle("clock")
    }
}
