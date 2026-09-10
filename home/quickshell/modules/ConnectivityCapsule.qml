import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import ".."
import "../components"

// One pill, three independently-clickable icons — each opens its own panel.
// Wi-Fi and Bluetooth panels cross-navigate via their footers; Volume is its
// own thing.
Rectangle {
    id: root
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + Theme.gap.lg * 2
    radius: Theme.radius.pill
    color: Theme.color.bgAlt
    border.width: 1
    border.color: Theme.color.surface

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property int volumePct: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) ?? null : null
    readonly property bool wifiUp: Networking.connectivity === NetworkConnectivity.Full

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.gap.lg

        BarIconValue {
            panelName: "volume"
            glyph: root.muted ? Icons.volumeMute : Icons.volumeUp
            tint: root.muted ? Theme.color.fgDim : Theme.color.teal
            value: root.sink ? String(root.volumePct) : ""
            onClicked: PanelState.toggle("volume")
        }

        BarIconValue {
            panelName: "bluetooth"
            glyph: Icons.bluetooth
            tint: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? Theme.color.teal : Theme.color.fgDim
            onClicked: PanelState.toggle("bluetooth")
        }

        BarIconValue {
            panelName: "wifi"
            glyph: Icons.wifi
            tint: root.wifiUp ? Theme.color.sand : Theme.color.fgDim
            value: root.activeNetwork ? String(Math.round(root.activeNetwork.signalStrength * 100)) : ""
            onClicked: PanelState.toggle("wifi")
        }
    }
}
