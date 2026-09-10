import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "wifi"
    edge: "right"
    sideMargin: 170

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) ?? null : null

    property string ipAddress: "—"
    property string band: "—"

    Process {
        id: netInfoProc
        command: ["bash", "-c",
            "nmcli -g IP4.ADDRESS device show " + (root.wifiDevice ? root.wifiDevice.name : "") + " 2>/dev/null | head -1; " +
            "nmcli -t -f active,freq dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                root.ipAddress = lines[0] || "—";
                const freq = parseInt(lines[1]);
                root.band = isNaN(freq) ? "—" : (freq < 3000 ? "2.4 GHz" : "5 GHz");
            }
        }
    }

    onOpenedChanged: if (opened) netInfoProc.running = true

    function signalLevel(strength) {
        if (strength >= 80) return 4;
        if (strength >= 55) return 3;
        if (strength >= 30) return 2;
        if (strength > 0) return 1;
        return 0;
    }

    PanelCard {
        subtitle: root.activeNetwork ? "Connected — " + root.activeNetwork.name : "Not connected"
        subtitleColor: root.activeNetwork ? Theme.color.green : Theme.color.fgDim
        headerGlyph: Icons.wifi
        statusColor: root.activeNetwork ? Theme.color.green : Theme.color.maroon

        ColumnLayout {
            id: connectedSection
            Layout.fillWidth: true
            spacing: Theme.gap.sm
            visible: root.activeNetwork !== null

            readonly property int signalPct: root.activeNetwork ? Math.round(root.activeNetwork.signalStrength * 100) : 0
            readonly property bool weak: signalPct < 30

            RingGauge {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.gap.xs
                Layout.bottomMargin: Theme.gap.xs
                width: 108
                height: 108
                value: root.activeNetwork ? root.activeNetwork.signalStrength : 0
                tint: connectedSection.weak ? Theme.color.maroon : Theme.color.teal
                glow: true
                pulse: connectedSection.weak

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: connectedSection.signalPct + "%"
                        color: Theme.color.fgBright
                        font.family: Theme.font.mono
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 84
                        text: root.activeNetwork ? root.activeNetwork.name : ""
                        color: Theme.color.fgDim
                        font.family: Theme.font.sans
                        font.pixelSize: Theme.font.sizeUi - 3
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            IconRow {
                Layout.fillWidth: true
                glyph: Icons.desktop
                tint: Theme.color.teal
                label: "IP address"
                value: root.ipAddress
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.gap.sm
                StatTile { label: "BAND"; glyph: Icons.signal; tint: Theme.color.teal; value: root.band }
                StatTile {
                    label: "SECURITY"
                    glyph: Icons.shield
                    tint: Theme.color.green
                    value: root.activeNetwork ? WifiSecurityType.toString(root.activeNetwork.security) : "—"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.color.surface
            visible: root.activeNetwork !== null
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.sm

            Repeater {
                model: root.wifiDevice ? root.wifiDevice.networks : null

                delegate: Item {
                    id: netItem
                    required property var modelData
                    visible: !modelData.connected
                    Layout.fillWidth: true
                    implicitHeight: rowContent.implicitHeight

                    IconRow {
                        id: rowContent
                        anchors.fill: parent
                        glyph: Icons.wifi
                        tint: netItem.modelData.known ? Theme.color.teal : Theme.color.fgDim
                        label: netItem.modelData.name
                        value: ""
                        SignalBars { level: root.signalLevel(netItem.modelData.signalStrength * 100) }
                    }

                    Ripple {
                        cornerRadius: Theme.radius.sm
                        onClicked: netItem.modelData.connect()
                    }
                }
            }
        }

        SegmentedFooter {
            segments: [
                { glyph: Icons.wifi, label: "Wi-Fi", active: true },
                { glyph: Icons.bluetooth, label: "Bluetooth", active: false },
                { glyph: Icons.plug, label: "Wired", active: false }
            ]
            onSegmentClicked: (index) => {
                if (index === 1) PanelState.toggle("bluetooth");
                else if (index === 2) PanelState.toggle("wired");
            }
        }
    }
}
