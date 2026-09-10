import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "bluetooth"
    edge: "right"
    sideMargin: 170

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevice: adapter ? adapter.devices.values.find(d => d.connected) ?? null : null
    readonly property var knownDevices: adapter ? adapter.devices.values.filter(d => d.paired && !d.connected) : []

    readonly property int connectedCount: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    PanelCard {
        subtitle: root.adapter && root.adapter.enabled
                  ? "On · " + root.connectedCount + " connected"
                  : "Off"
        subtitleColor: root.adapter && root.adapter.enabled ? Theme.color.green : Theme.color.fgDim
        headerGlyph: Icons.bluetooth
        statusColor: root.adapter && root.adapter.enabled ? Theme.color.green : Theme.color.maroon

        IconRow {
            Layout.fillWidth: true
            glyph: Icons.bluetooth
            tint: root.adapter && root.adapter.enabled ? Theme.color.teal : Theme.color.fgDim
            label: root.adapter && root.adapter.enabled ? "Bluetooth on" : "Bluetooth off"

            Item {
                implicitWidth: 40
                implicitHeight: 22

                Rectangle {
                    visible: root.adapter && root.adapter.enabled
                    anchors.centerIn: parent
                    width: parent.width + 14; height: parent.height + 14; radius: height / 2
                    color: Theme.color.accent
                    opacity: 0.18
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 11
                    color: root.adapter && root.adapter.enabled ? Theme.color.accent : Theme.color.muted
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: Theme.color.fgBright
                        anchors.verticalCenter: parent.verticalCenter
                        x: (root.adapter && root.adapter.enabled) ? parent.width - width - 2 : 2
                        Behavior on x { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }
                    }

                    Ripple {
                        cornerRadius: 11
                        onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs
            visible: root.connectedDevice !== null && !root.connectedDevice.batteryAvailable

            IconRow {
                Layout.fillWidth: true
                glyph: Icons.bluetoothB
                tint: Theme.color.green
                label: root.connectedDevice ? (root.connectedDevice.deviceName || root.connectedDevice.name) : ""
                value: "connected"
            }
        }

        // A connected device reporting its own battery gets the same
        // hero-ring treatment as Volume/Battery/Wifi — otherwise there's
        // nothing worth promoting above the plain "connected" row above.
        RingGauge {
            visible: root.connectedDevice !== null && root.connectedDevice.batteryAvailable
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.gap.xs
            Layout.bottomMargin: Theme.gap.xs
            width: 108
            height: 108
            value: root.connectedDevice ? root.connectedDevice.battery : 0
            tint: (root.connectedDevice && root.connectedDevice.battery < 0.2) ? Theme.color.maroon : Theme.color.green
            glow: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.connectedDevice ? Math.round(root.connectedDevice.battery * 100) + "%" : ""
                    color: Theme.color.fgBright
                    font.family: Theme.font.mono
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 84
                    text: root.connectedDevice ? (root.connectedDevice.deviceName || root.connectedDevice.name) : ""
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 3
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs
            visible: root.knownDevices.length > 0

            Repeater {
                model: root.knownDevices

                delegate: Item {
                    id: knownItem
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: knownRow.implicitHeight

                    IconRow {
                        id: knownRow
                        anchors.fill: parent
                        glyph: Icons.bluetooth
                        tint: Theme.color.fgDim
                        label: knownItem.modelData.deviceName || knownItem.modelData.name
                        value: "reconnect"
                    }

                    Ripple {
                        cornerRadius: Theme.radius.sm
                        onClicked: knownItem.modelData.connect()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: Theme.radius.md
            color: "transparent"
            border.width: 1
            border.color: Theme.color.muted

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.color.muted
                opacity: 0.15
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.gap.sm
                spacing: Theme.gap.sm

                Text {
                    text: root.adapter && root.adapter.discovering ? "Scanning for devices…" : "Pairing mode"
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi
                    font.italic: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: root.adapter && root.adapter.discovering
                    width: 6; height: 6; radius: 3
                    color: Theme.color.sand
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: root.adapter && root.adapter.discovering
                        NumberAnimation { to: 0.2; duration: 600 }
                        NumberAnimation { to: 1; duration: 600 }
                    }
                }
            }

            Ripple {
                cornerRadius: Theme.radius.md
                onClicked: if (root.adapter) root.adapter.discovering = !root.adapter.discovering
            }
        }

        SegmentedFooter {
            segments: [
                { glyph: Icons.wifi, label: "Wi-Fi", active: false },
                { glyph: Icons.bluetooth, label: "Bluetooth", active: true },
                { glyph: Icons.plug, label: "Wired", active: false }
            ]
            onSegmentClicked: (index) => {
                if (index === 0) PanelState.toggle("wifi");
                else if (index === 2) PanelState.toggle("wired");
            }
        }
    }
}
