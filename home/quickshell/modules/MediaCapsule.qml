import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import ".."

Rectangle {
    id: root
    property bool caffeineOn: false
    signal toggleCaffeine()

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + Theme.gap.md * 2
    radius: Theme.radius.pill
    color: Theme.color.bgAlt
    border.width: 1
    border.color: Theme.color.surface

    readonly property bool playing: Mpris.players.values.some(p => p.isPlaying)

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.gap.md

        Text {
            id: musicIcon
            text: Icons.music
            font.family: Theme.font.icon
            font.pixelSize: 14
            color: root.playing ? Theme.color.teal : Theme.color.fgDim

            function reportPosition() {
                if (width > 0) PanelState.reportPillX("media", mapToGlobal(width / 2, 0).x);
            }
            onXChanged: reportPosition()
            Component.onCompleted: reportPosition()
            Timer { interval: 300; running: true; onTriggered: musicIcon.reportPosition() }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: PanelState.toggle("media")
            }
        }

        Text {
            text: Icons.coffee
            font.family: Theme.font.icon
            font.pixelSize: 14
            color: root.caffeineOn ? Theme.color.sand : Theme.color.fgDim

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleCaffeine()
            }
        }
    }
}
