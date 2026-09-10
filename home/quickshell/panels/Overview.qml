import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import ".."
import "../components"

// SUPER (tap) opens this: a unified app launcher + zoomed-out workspace grid,
// end-4-style. Drag a window chip from one workspace card to another to move
// it (confirmed working via focus-by-address then move-to-workspace — see
// the two Hyprland.dispatch calls in moveWindowTo()).
PanelWindow {
    id: root
    readonly property bool opened: PanelState.openPanel === "overview"
    visible: opened

    color: "transparent"
    anchors { top: true; left: true; right: true; bottom: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ember-overview"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property var apps: []

    // Real monitor resolution — the overview scales window chips by this so
    // each workspace card is a true miniature of the real screen, windows
    // positioned exactly where they really sit (mission-control style).
    readonly property real screenW: root.screen ? root.screen.width : root.width
    readonly property real screenH: root.screen ? root.screen.height : root.height

    onOpenedChanged: {
        if (opened) {
            root.query = "";
            listAppsProc.running = true;
            searchField.forceActiveFocus();
        }
    }

    Process {
        id: listAppsProc
        command: ["bash", "-c", "python3 \"$HOME/.config/quickshell/scripts/list-apps.py\""]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.apps = JSON.parse(text); } catch (e) { root.apps = []; }
            }
        }
    }

    readonly property var filteredApps: {
        const q = root.query.trim().toLowerCase();
        if (q.length === 0) return [];
        return root.apps.filter(a => a.name.toLowerCase().includes(q)).slice(0, 6);
    }

    Process { id: launchProc }
    function launch(app) {
        launchProc.command = app.terminal
            ? ["bash", "-c", "kitty -e " + app.exec]
            : ["bash", "-c", app.exec];
        launchProc.running = true;
        PanelState.close();
    }

    function switchTo(wsName) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsName + " })");
        PanelState.close();
    }

    function moveWindowTo(address, wsName) {
        Hyprland.dispatch("hl.dsp.focus({ window = \"address:" + address + "\" })");
        moveRetimer.targetWs = wsName;
        moveRetimer.start();
    }
    Timer {
        id: moveRetimer
        property string targetWs: ""
        interval: 60
        onTriggered: Hyprland.dispatch("hl.dsp.window.move({ workspace = " + targetWs + " })")
    }

    // Ambient dim behind the content, so the overview reads as its own
    // surface rather than a transparent hole in the screen.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.063, 0.078, 0.122, 0.86)
        MouseArea { anchors.fill: parent; onClicked: PanelState.close() }
    }

    Item {
        id: shell
        opacity: root.opened ? 1 : 0
        scale: root.opened ? 1 : 0.98
        anchors.fill: parent
        anchors.margins: 28
        Behavior on opacity { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gap.md

            // === Search / launcher — compact, only grows when you type ===
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.gap.sm

                Rectangle {
                    Layout.preferredWidth: 440
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 46
                    radius: Theme.radius.lg
                    color: Qt.rgba(0.086, 0.11, 0.169, 0.97)
                    border.width: 1
                    border.color: Theme.color.accent

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.gap.md
                        anchors.rightMargin: Theme.gap.md
                        spacing: Theme.gap.sm

                        Text {
                            text: Icons.search
                            font.family: Theme.font.icon
                            font.pixelSize: 15
                            color: Theme.color.accent
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            text: root.query
                            onTextChanged: root.query = text
                            color: Theme.color.fgBright
                            font.family: Theme.font.sans
                            font.pixelSize: 15
                            clip: true
                            Keys.onReturnPressed: if (root.filteredApps.length > 0) root.launch(root.filteredApps[0])
                            Keys.onEscapePressed: PanelState.close()

                            Text {
                                visible: parent.text.length === 0
                                text: "Search apps, or click a workspace…"
                                color: Theme.color.fgDim
                                font: parent.font
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.gap.sm
                    visible: root.filteredApps.length > 0

                    Repeater {
                        model: root.filteredApps
                        delegate: Rectangle {
                            required property var modelData
                            implicitWidth: 84
                            implicitHeight: 78
                            radius: Theme.radius.md
                            color: appMouse.containsMouse ? Theme.color.surface : Theme.color.bgAlt
                            border.width: 1
                            border.color: Theme.color.surface
                            Behavior on color { ColorAnimation { duration: 120 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                IconImage {
                                    Layout.alignment: Qt.AlignHCenter
                                    implicitSize: 30
                                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: 76
                                    text: modelData.name
                                    color: Theme.color.fg
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.sizeUi - 3
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launch(modelData)
                            }
                        }
                    }
                }
            }

            // === Workspace grid — fills essentially the whole screen. Each
            // cell is a true miniature of the real monitor (locked to its
            // aspect ratio), windows placed at their real relative position.
            Item {
                id: gridArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property int wsCount: Math.max(1, Hyprland.workspaces.values.length)
                readonly property int cols: Math.ceil(Math.sqrt(wsCount))
                readonly property int rows: Math.ceil(wsCount / cols)
                readonly property real gap: Theme.gap.lg

                // Fit the largest screen-aspect-ratio cells that tile cols x rows
                // inside the available area.
                readonly property real aspect: root.screenW / root.screenH
                readonly property real availW: width - gap * (cols - 1)
                readonly property real availH: height - gap * (rows - 1)
                readonly property real cellWByWidth: availW / cols
                readonly property real cellHByWidth: cellWByWidth / aspect
                readonly property real cellHByHeight: availH / rows
                readonly property real cellWByHeight: cellHByHeight * aspect
                readonly property real cellW: cellHByWidth * rows <= availH ? cellWByWidth : cellWByHeight
                readonly property real cellH: cellHByWidth * rows <= availH ? cellHByWidth : cellHByHeight
                readonly property real gridW: cellW * cols + gap * (cols - 1)
                readonly property real gridH: cellH * rows + gap * (rows - 1)

                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    columns: gridArea.cols
                    rowSpacing: gridArea.gap
                    columnSpacing: gridArea.gap

                    Repeater {
                        model: Hyprland.workspaces

                        delegate: Rectangle {
                            id: wsCard
                            required property var modelData
                            width: gridArea.cellW
                            height: gridArea.cellH
                            radius: Theme.radius.lg
                            color: Theme.color.bgAlt
                            border.width: modelData.active ? 3 : 1
                            border.color: modelData.active ? Theme.color.accent : Theme.color.surface
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            DropArea {
                                anchors.fill: parent
                                onEntered: wsCard.border.color = Theme.color.sand
                                onExited: wsCard.border.color = wsCard.modelData.active ? Theme.color.accent : Theme.color.surface
                                onDropped: (drop) => {
                                    if (drop.source && drop.source.windowAddress) {
                                        root.moveWindowTo(drop.source.windowAddress, wsCard.modelData.name);
                                    }
                                    wsCard.border.color = wsCard.modelData.active ? Theme.color.accent : Theme.color.surface;
                                }
                            }

                            RowLayout {
                                anchors { top: parent.top; left: parent.left; right: parent.right; margins: Theme.gap.sm }
                                spacing: 6

                                Rectangle {
                                    width: 9; height: 9; radius: 4.5
                                    color: wsCard.modelData.active ? Theme.color.accent : Theme.color.muted
                                }
                                Text {
                                    text: "Workspace " + wsCard.modelData.name
                                    color: wsCard.modelData.active ? Theme.color.fgBright : Theme.color.fgDim
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.sizeUi + 1
                                    font.weight: Font.DemiBold
                                }
                            }

                            // Windows placed at their real relative on-screen
                            // position/size, scaled to this card.
                            Item {
                                id: winArea
                                anchors.fill: parent
                                anchors.margins: 10
                                anchors.topMargin: 32
                                readonly property real sx: width / root.screenW
                                readonly property real sy: height / root.screenH

                                Repeater {
                                    model: Hyprland.toplevels.values.filter(t => t.workspace === wsCard.modelData)

                                    delegate: Rectangle {
                                        id: chip
                                        required property var modelData
                                        readonly property string windowAddress: modelData.address
                                        readonly property var ipc: modelData.lastIpcObject
                                        readonly property var atPos: (ipc && ipc.at) || [0, 0]
                                        readonly property var sizePos: (ipc && ipc.size) || [root.screenW, root.screenH]

                                        x: Math.max(0, atPos[0] * winArea.sx)
                                        y: Math.max(0, atPos[1] * winArea.sy)
                                        width: Math.max(28, Math.min(sizePos[0] * winArea.sx, winArea.width - x))
                                        height: Math.max(22, Math.min(sizePos[1] * winArea.sy, winArea.height - y))
                                        radius: Theme.radius.sm
                                        clip: true
                                        color: modelData.urgent ? Theme.color.maroon : Theme.color.bg
                                        border.width: modelData.activated ? 2 : 1
                                        border.color: modelData.activated ? Theme.color.accent : Theme.color.muted

                                        Drag.active: chipMouse.drag.active
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2

                                        // Live thumbnail of the actual window contents. Falls back to
                                        // an app icon if capture never lands for this surface.
                                        ScreencopyView {
                                            id: capture
                                            anchors.fill: parent
                                            live: true
                                            paintCursor: false
                                            captureSource: chip.modelData.wayland
                                        }

                                        IconImage {
                                            anchors.centerIn: parent
                                            implicitSize: Math.min(32, chip.width * 0.4, chip.height * 0.4)
                                            visible: !capture.hasContent
                                            source: Quickshell.iconPath(
                                                (chip.modelData.lastIpcObject && chip.modelData.lastIpcObject.class) || "",
                                                "application-x-executable")
                                        }

                                        Rectangle {
                                            visible: chip.height > 30
                                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                            height: 18
                                            color: Qt.rgba(0.039, 0.047, 0.071, 0.75)
                                            Text {
                                                anchors.centerIn: parent
                                                width: parent.width - 8
                                                text: chip.modelData.title
                                                color: Theme.color.fgBright
                                                font.family: Theme.font.sans
                                                font.pixelSize: Theme.font.sizeUi - 4
                                                horizontalAlignment: Text.AlignHCenter
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            id: chipMouse
                                            anchors.fill: parent
                                            drag.target: parent
                                            cursorShape: Qt.OpenHandCursor
                                            onPressed: chip.z = 10
                                            onReleased: {
                                                chip.Drag.drop();
                                                chip.z = 0;
                                                chip.x = Qt.binding(() => Math.max(0, chip.atPos[0] * winArea.sx));
                                                chip.y = Qt.binding(() => Math.max(0, chip.atPos[1] * winArea.sy));
                                            }
                                            onClicked: root.switchTo(wsCard.modelData.name)
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: Hyprland.toplevels.values.filter(t => t.workspace === wsCard.modelData).length === 0
                                text: "empty"
                                color: Theme.color.fgDim
                                font.family: Theme.font.sans
                                font.italic: true
                                font.pixelSize: Theme.font.sizeUi
                            }

                            MouseArea {
                                anchors.fill: parent
                                z: -1
                                onClicked: root.switchTo(wsCard.modelData.name)
                            }
                        }
                    }
                }
            }
        }
    }
}
