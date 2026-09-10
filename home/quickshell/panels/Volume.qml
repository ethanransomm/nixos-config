import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "volume"
    edge: "right"
    sideMargin: 170

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream && n.audio)

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Process {
        id: setDefaultSink
        command: ["true"]
    }

    function setDefault(node) {
        setDefaultSink.command = ["wpctl", "set-default", String(node.id)];
        setDefaultSink.running = true;
    }

    PanelCard {
        subtitle: root.sink ? (root.sink.description || root.sink.name) : ""
        headerGlyph: Icons.volumeUp
        statusColor: root.sink && root.sink.audio && root.sink.audio.muted ? Theme.color.maroon : Theme.color.green

        // --- Hero orb — adapted from ilyamiro/serpantinum's VolumePopup:
        // a liquid fill-level rendered as an animated sine wave rather than
        // a bare percentage number. Visual only; the thin slider below it
        // still does the actual dragging, so this doesn't need to solve
        // "precise circular drag gesture" to earn its place.
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.gap.xs
            Layout.bottomMargin: Theme.gap.sm
            implicitWidth: 132
            implicitHeight: 132

            readonly property bool muted: root.sink && root.sink.audio && root.sink.audio.muted
            readonly property int volumePct: root.sink && root.sink.audio ? Math.round(root.sink.audio.volume * 100) : 0
            readonly property color orbColor: muted ? Theme.color.maroon : Theme.color.teal

            // soft ambient glow behind the orb
            Rectangle {
                anchors.centerIn: parent
                width: 150; height: 150; radius: 75
                color: parent.orbColor
                opacity: 0.10
            }

            // breathing outer ring
            Rectangle {
                id: pulseRing
                anchors.centerIn: parent
                width: 132; height: 132; radius: 66
                color: "transparent"
                border.width: 1.5
                border.color: Qt.rgba(parent.orbColor.r, parent.orbColor.g, parent.orbColor.b, glow)
                property real glow: 0.7
                SequentialAnimation on glow {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.25; to: 0.7; duration: 1800; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.7; to: 0.25; duration: 1800; easing.type: Easing.InOutSine }
                }
            }

            Rectangle {
                id: orbCore
                anchors.centerIn: parent
                width: 112; height: 112; radius: 56
                color: Theme.color.bg
                border.width: 2
                border.color: parent.orbColor
                clip: true
                Behavior on border.color { ColorAnimation { duration: 250 } }

                Canvas {
                    id: wave
                    anchors.fill: parent
                    property real phase: 0
                    NumberAnimation on phase {
                        running: !orbCore.parent.muted && orbCore.parent.volumePct > 0
                        loops: Animation.Infinite
                        from: 0; to: Math.PI * 2; duration: 2400
                    }
                    onPhaseChanged: requestPaint()
                    Connections {
                        target: orbCore.parent
                        function onVolumePctChanged() { wave.requestPaint(); }
                        function onMutedChanged() { wave.requestPaint(); }
                    }
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        const pct = orbCore.parent.muted ? 0 : orbCore.parent.volumePct;
                        if (pct <= 0) return;

                        // Rectangle's clip:true only clips to its rectangular
                        // bounding box, not its rounded/circular shape — clip
                        // the canvas's own drawing to a circle so the wave
                        // fill can't spill into the corners outside the orb.
                        ctx.save();
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2);
                        ctx.clip();

                        const fillY = height * (1 - pct / 100);
                        const amp = 3.5;
                        const wavelen = width / 1.4;
                        ctx.beginPath();
                        ctx.moveTo(0, height);
                        ctx.lineTo(0, fillY);
                        for (let x = 0; x <= width; x += 3) {
                            const y = fillY + Math.sin((x / wavelen) * Math.PI * 2 + wave.phase) * amp;
                            ctx.lineTo(x, y);
                        }
                        ctx.lineTo(width, height);
                        ctx.closePath();
                        const c = orbCore.parent.orbColor;
                        ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, 0.35);
                        ctx.fill();
                        ctx.restore();
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: orbCore.parent.muted ? Icons.volumeMute : Icons.volumeUp
                    font.family: Theme.font.icon
                    font.pixelSize: 15
                    color: Theme.color.fgDim
                    y: -14
                }
                Text {
                    anchors.centerIn: parent
                    y: 10
                    text: orbCore.parent.volumePct + "%"
                    font.family: Theme.font.mono
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: Theme.color.fgBright
                }
            }

            MouseArea {
                anchors.fill: orbCore
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted
            }
        }

        // --- Master slider ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs

            Rectangle {
                id: masterTrack
                Layout.fillWidth: true
                implicitHeight: 16
                radius: 8
                color: Theme.color.bg

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * (root.sink && root.sink.audio ? Math.min(1, root.sink.audio.volume) : 0)
                    radius: parent.radius
                    color: Theme.color.accent
                }

                Rectangle {
                    // grab handle
                    width: 16
                    height: 16
                    radius: 8
                    color: Theme.color.fgBright
                    border.width: 2
                    border.color: Theme.color.accent
                    x: Math.max(0, Math.min(masterTrack.width - width,
                        masterTrack.width * (root.sink && root.sink.audio ? root.sink.audio.volume : 0) - width / 2))
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: (mouse) => updateFromX(mouse.x)
                    onPositionChanged: (mouse) => { if (pressed) updateFromX(mouse.x) }
                    function updateFromX(x) {
                        if (!root.sink || !root.sink.audio) return;
                        root.sink.audio.volume = Math.max(0, Math.min(1, x / width));
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.color.surface }

        // --- Output device picker ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs

            Text {
                text: "Output device"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi - 1
            }

            Repeater {
                model: root.sinks

                delegate: Rectangle {
                    id: sinkTile
                    required property var modelData
                    readonly property bool selected: modelData === root.sink
                    Layout.fillWidth: true
                    implicitHeight: sinkRow.implicitHeight + Theme.gap.xs * 2
                    radius: Theme.radius.md
                    color: selected ? Qt.rgba(Theme.color.green.r, Theme.color.green.g, Theme.color.green.b, 0.12) : "transparent"
                    border.width: selected ? 1 : 0
                    border.color: Theme.color.green
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }

                    IconRow {
                        id: sinkRow
                        anchors.fill: parent
                        anchors.margins: Theme.gap.xs
                        glyph: sinkTile.selected ? Icons.check : Icons.volumeUp
                        tint: sinkTile.selected ? Theme.color.green : Theme.color.fgDim
                        label: sinkTile.modelData.description || sinkTile.modelData.name
                    }

                    Ripple {
                        cornerRadius: Theme.radius.md
                        onClicked: root.setDefault(sinkTile.modelData)
                    }
                }
            }
        }

        // --- Per-app streams ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.sm
            visible: root.streams.length > 0

            Text {
                text: "Apps"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi - 1
            }

            Repeater {
                model: root.streams

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.description || modelData.name
                            color: Theme.color.fg
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: Math.round(modelData.audio.volume * 100) + "%"
                            color: Theme.color.fgDim
                            font.family: Theme.font.mono
                            font.pixelSize: Theme.font.sizeUi - 1
                        }
                    }

                    Rectangle {
                        id: appTrack
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 5
                        color: Theme.color.bg

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: parent.width * Math.min(1, modelData.audio.volume)
                            radius: parent.radius
                            color: Theme.color.teal
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: (mouse) => modelData.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                            onPositionChanged: (mouse) => { if (pressed) modelData.audio.volume = Math.max(0, Math.min(1, mouse.x / width)) }
                        }
                    }
                }
            }
        }
    }
}
