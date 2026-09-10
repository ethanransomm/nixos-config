import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "media"
    edge: "right"
    sideMargin: 340

    readonly property var player: {
        const list = Mpris.players.values;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    // --- position interpolation: MPRIS players rarely push Position updates
    // during playback, so we resync on real signals and tick locally between
    // them (the "poll Position live" fix the brief calls for). ---
    property real basePosition: 0
    property real baseTimestamp: Date.now()
    property real displayPosition: 0
    property int presetIndex: 0
    readonly property var eqPresetIcons: [Icons.moon, Icons.tint, Icons.heart]
    readonly property var eqPresetTints: [Theme.color.teal, Theme.color.sand, Theme.color.maroon]

    function resync() {
        root.basePosition = root.player ? root.player.position : 0;
        root.baseTimestamp = Date.now();
        root.displayPosition = root.basePosition;
    }

    onPlayerChanged: resync()

    Connections {
        target: root.player
        function onTrackChanged() { root.resync(); }
        function onPositionChanged() { root.resync(); }
    }

    Timer {
        interval: 500
        running: root.player && root.player.isPlaying
        repeat: true
        onTriggered: {
            const len = root.player.length > 0 ? root.player.length : 1e9;
            root.displayPosition = Math.min(len, root.basePosition + (Date.now() - root.baseTimestamp) / 1000);
        }
    }

    function fmt(seconds) {
        if (!seconds || seconds < 0 || !isFinite(seconds)) return "0:00";
        const m = Math.floor(seconds / 60);
        const s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    PanelCard {
        width: 340
        headerGlyph: Icons.music
        statusColor: root.player && root.player.isPlaying ? Theme.color.green : Theme.color.fgDim

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.md
            visible: root.player !== null

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.gap.md

                Rectangle {
                    width: 64
                    height: 64
                    radius: Theme.radius.md
                    color: Theme.color.surface
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !(root.player && root.player.trackArtUrl)
                        text: Icons.music
                        font.family: Theme.font.icon
                        font.pixelSize: 22
                        color: Theme.color.fgDim
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.player ? (root.player.trackTitle || "Unknown track") : ""
                        color: Theme.color.fgBright
                        font.family: Theme.font.sans
                        font.pixelSize: Theme.font.sizeUi + 1
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.player ? (root.player.trackArtist || "") : ""
                        color: Theme.color.fgDim
                        font.family: Theme.font.sans
                        font.pixelSize: Theme.font.sizeUi - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: badgeLabel.implicitWidth + 12
                        implicitHeight: 18
                        radius: 9
                        color: Theme.color.bg
                        Text {
                            id: badgeLabel
                            anchors.centerIn: parent
                            text: root.player ? root.player.identity : ""
                            color: Theme.color.teal
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi - 3
                        }
                    }
                }
            }

            // --- scrubber ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.color.bg

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        radius: parent.radius
                        color: Theme.color.accent
                        width: (root.player && root.player.length > 0)
                               ? parent.width * Math.min(1, root.displayPosition / root.player.length)
                               : 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (mouse) => seekTo(mouse.x)
                        onPositionChanged: (mouse) => { if (pressed) seekTo(mouse.x); }
                        function seekTo(x) {
                            if (!root.player || !root.player.canSeek || root.player.length <= 0) return;
                            const target = Math.max(0, Math.min(1, x / width)) * root.player.length;
                            root.player.seek(target - root.displayPosition);
                            root.basePosition = target;
                            root.baseTimestamp = Date.now();
                            root.displayPosition = target;
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.fmt(root.displayPosition)
                        color: Theme.color.fgDim
                        font.family: Theme.font.mono
                        font.pixelSize: Theme.font.sizeUi - 2
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.player ? root.fmt(root.player.length) : "0:00"
                        color: Theme.color.fgDim
                        font.family: Theme.font.mono
                        font.pixelSize: Theme.font.sizeUi - 2
                    }
                }
            }

            // --- transport controls ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.gap.lg

                Text {
                    text: Icons.prev
                    font.family: Theme.font.icon
                    font.pixelSize: 16
                    color: root.player && root.player.canGoPrevious ? Theme.color.fg : Theme.color.muted
                    Ripple { anchors.margins: -8; cornerRadius: height / 2; onClicked: root.player && root.player.previous() }
                }
                Text {
                    text: root.player && root.player.isPlaying ? Icons.pause : Icons.play
                    font.family: Theme.font.icon
                    font.pixelSize: 20
                    color: Theme.color.accent
                    Ripple { anchors.margins: -8; cornerRadius: height / 2; onClicked: root.player && root.player.togglePlaying() }
                }
                Text {
                    text: Icons.next
                    font.family: Theme.font.icon
                    font.pixelSize: 16
                    color: root.player && root.player.canGoNext ? Theme.color.fg : Theme.color.muted
                    Ripple { anchors.margins: -8; cornerRadius: height / 2; onClicked: root.player && root.player.next() }
                }
            }

            // --- decorative curved equalizer ---
            EqCanvas {
                Layout.fillWidth: true
                height: 40
                playing: root.player && root.player.isPlaying
                preset: root.presetIndex
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.gap.sm
                Repeater {
                    model: ["Calm", "Wave", "Pulse"]
                    delegate: Rectangle {
                        id: presetPill
                        required property string modelData
                        required property int index
                        readonly property bool active: root.presetIndex === index
                        readonly property color accentTint: root.eqPresetTints[index]
                        implicitWidth: pillRow.implicitWidth + Theme.gap.sm * 2
                        implicitHeight: 24
                        radius: Theme.radius.pill
                        color: active ? Qt.rgba(accentTint.r, accentTint.g, accentTint.b, 0.16) : "transparent"
                        border.width: 1
                        border.color: active ? accentTint : Theme.color.surface
                        Behavior on color { ColorAnimation { duration: Theme.animDuration } }

                        RowLayout {
                            id: pillRow
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                text: root.eqPresetIcons[presetPill.index]
                                font.family: Theme.font.icon
                                font.pixelSize: 10
                                color: presetPill.active ? presetPill.accentTint : Theme.color.fgDim
                            }
                            Text {
                                text: presetPill.modelData
                                color: presetPill.active ? Theme.color.fgBright : Theme.color.fgDim
                                font.family: Theme.font.sans
                                font.pixelSize: Theme.font.sizeUi - 2
                                font.weight: presetPill.active ? Font.DemiBold : Font.Normal
                            }
                        }

                        Ripple {
                            cornerRadius: Theme.radius.pill
                            onClicked: root.presetIndex = presetPill.index
                        }
                    }
                }
            }
        }

        Text {
            visible: root.player === null
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Nothing playing"
            color: Theme.color.fgDim
            font.family: Theme.font.sans
            font.pixelSize: Theme.font.sizeUi
        }
    }
}
