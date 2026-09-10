import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import ".."
import "../components"

// One pill, three independently-clickable icons — laptop control, battery
// (which also carries the power grid — see panels/Battery.qml), notifications.
Rectangle {
    id: root

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + Theme.gap.lg * 2
    radius: Theme.radius.pill
    color: Theme.color.bgAlt
    border.width: 1
    border.color: Theme.color.surface

    readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.gap.lg

        BarIconValue {
            panelName: "laptop"
            glyph: Icons.microchip
            tint: Theme.color.green
            value: SystemStats.currentWatts >= 0 ? String(Math.round(SystemStats.currentWatts)) : ""
            onClicked: PanelState.toggle("laptop")
        }

        BarIconValue {
            panelName: "battery"
            glyph: root.battery && root.battery.percentage < 0.2 ? Icons.batteryHalf : Icons.battery
            tint: root.battery && root.battery.percentage < 0.2 ? Theme.color.maroon : Theme.color.sand
            value: root.battery ? String(Math.round(root.battery.percentage * 100)) : ""
            onClicked: PanelState.toggle("battery")
        }

        Item {
            id: bellItem
            implicitWidth: bellIcon.implicitWidth
            implicitHeight: bellIcon.implicitHeight

            function reportPosition() {
                if (width > 0) PanelState.reportPillX("notifications", mapToGlobal(width / 2, 0).x);
            }
            onXChanged: reportPosition()
            onWidthChanged: reportPosition()
            Component.onCompleted: reportPosition()
            Timer { interval: 300; running: true; onTriggered: bellItem.reportPosition() }

            Text {
                id: bellIcon
                text: Icons.bell
                font.family: Theme.font.icon
                font.pixelSize: 15
                color: Theme.color.accent
            }

            Rectangle {
                visible: NotifStore.notifications.values.length > 0
                width: 6
                height: 6
                radius: 3
                color: Theme.color.maroon
                anchors { right: bellIcon.right; top: bellIcon.top; rightMargin: -2; topMargin: -2 }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -7
                cursorShape: Qt.PointingHandCursor
                onClicked: PanelState.toggle("notifications")
            }
        }
    }
}
