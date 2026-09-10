import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "clipboard"
    edge: "float"

    property var entries: [] // [{ id, preview, isImage, imagePath }]
    property var decodeQueue: []
    property string query: ""
    readonly property var filteredEntries: query.length === 0
        ? entries
        : entries.filter(e => e.preview.toLowerCase().includes(query.toLowerCase()))

    function refresh() { listProc.running = true; }

    onOpenedChanged: if (opened) root.refresh()

    // Catch anything copied while the panel is sitting open.
    Timer {
        interval: 1500
        running: root.opened
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.length > 0);
                const oldById = {};
                for (const e of root.entries) oldById[e.id] = e;

                const newEntries = lines.map(l => {
                    const tab = l.indexOf("\t");
                    const id = l.slice(0, tab);
                    const preview = l.slice(tab + 1);
                    const isImage = preview.startsWith("[[");
                    const prev = oldById[id];
                    // keep whatever's already been decoded — re-running `cliphist
                    // list` on the refresh timer shouldn't blank out and
                    // re-decode every image, that's what was causing the flicker
                    return { id, preview, isImage, imagePath: prev ? prev.imagePath : "" };
                });

                const unchanged = newEntries.length === root.entries.length
                    && newEntries.every((e, i) => e.id === root.entries[i].id && e.imagePath === root.entries[i].imagePath);
                if (unchanged) return;

                root.entries = newEntries;
                root.decodeQueue = newEntries.filter(e => e.isImage && e.imagePath.length === 0).map(e => e.id);
                root.decodeNext();
            }
        }
    }

    property string decodingId: ""
    property string decodingPath: ""

    Process {
        id: decodeProc
        onExited: (exitCode) => {
            if (exitCode === 0 && root.decodingId.length > 0) {
                const idx = root.entries.findIndex(e => e.id === root.decodingId);
                if (idx >= 0) {
                    const copy = root.entries.slice();
                    copy[idx] = Object.assign({}, copy[idx], { imagePath: root.decodingPath });
                    root.entries = copy;
                }
            }
            root.decodeNext();
        }
    }
    function decodeNext() {
        if (root.decodeQueue.length === 0) { root.decodingId = ""; return; }
        const id = root.decodeQueue[0];
        root.decodeQueue = root.decodeQueue.slice(1);
        root.decodingId = id;
        root.decodingPath = "/tmp/quickshell-clip-" + id + ".png";
        decodeProc.command = ["bash", "-c", "cliphist decode " + id + " > '" + root.decodingPath + "' 2>/dev/null"];
        decodeProc.running = true;
    }

    Process { id: copyProc }
    function copyEntry(id) {
        copyProc.command = ["bash", "-c", "cliphist decode " + id + " | wl-copy"];
        copyProc.running = true;
        PanelState.close();
    }

    Process {
        id: deleteProc
        onExited: root.refresh()
    }
    function deleteEntry(preview) {
        deleteProc.command = ["cliphist", "delete-query", preview];
        deleteProc.running = true;
    }

    Process { id: wipeProc }
    function wipeAll() {
        wipeProc.command = ["cliphist", "wipe"];
        wipeProc.running = true;
        root.entries = [];
    }

    PanelCard {
        width: 640
        subtitle: root.entries.length + (root.entries.length === 1 ? " item" : " items")
        headerGlyph: Icons.clipboard
        statusColor: Theme.color.teal

        // search — same language as the Overview app launcher
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            radius: Theme.radius.md
            color: Theme.color.bg
            border.width: 1
            border.color: searchField.activeFocus ? Theme.color.accent : Theme.color.surface
            visible: root.entries.length > 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.gap.sm
                anchors.rightMargin: Theme.gap.sm
                spacing: Theme.gap.sm

                Text {
                    text: Icons.search
                    font.family: Theme.font.icon
                    font.pixelSize: 13
                    color: Theme.color.fgDim
                }

                TextInput {
                    id: searchField
                    Layout.fillWidth: true
                    text: root.query
                    onTextChanged: root.query = text
                    color: Theme.color.fg
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi
                    clip: true
                    Keys.onEscapePressed: if (text.length > 0) text = ""; else PanelState.close()

                    Text {
                        visible: parent.text.length === 0
                        text: "Search clipboard history…"
                        color: Theme.color.fgDim
                        font: parent.font
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.md
            visible: root.entries.length === 0

            Text {
                Layout.fillWidth: true
                Layout.topMargin: Theme.gap.md
                Layout.bottomMargin: Theme.gap.md
                horizontalAlignment: Text.AlignHCenter
                text: Icons.clipboard
                font.family: Theme.font.icon
                font.pixelSize: 26
                color: Theme.color.muted
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Nothing copied yet"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: Theme.gap.md
            horizontalAlignment: Text.AlignHCenter
            visible: root.entries.length > 0 && root.filteredEntries.length === 0
            text: "No matches for “" + root.query + "”"
            color: Theme.color.fgDim
            font.family: Theme.font.sans
            font.pixelSize: Theme.font.sizeUi
        }

        // fixed-height, scrollable — the list no longer grows the panel itself
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(420, grid.implicitHeight)
            visible: root.filteredEntries.length > 0
            clip: true

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.rightMargin: 8
                contentWidth: width
                contentHeight: grid.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                GridLayout {
                    id: grid
                    width: flick.width
                    columns: 2
                    rowSpacing: Theme.gap.sm
                    columnSpacing: Theme.gap.sm

                    Repeater {
                        model: root.filteredEntries

                        delegate: Rectangle {
                        id: row
                        required property var modelData
                        Layout.columnSpan: modelData.isImage ? 1 : 2
                        Layout.fillWidth: true
                        implicitHeight: modelData.isImage ? 120 : 40
                        radius: Theme.radius.md
                        color: rowMouse.containsMouse ? Theme.color.surface : Theme.color.bg
                        clip: true
                        Behavior on color { ColorAnimation { duration: 100 } }

                        // --- image entry ---
                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            visible: row.modelData.isImage && row.modelData.imagePath.length > 0
                            source: visible ? "file://" + row.modelData.imagePath : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }

                        Text {
                            visible: row.modelData.isImage && row.modelData.imagePath.length === 0
                            anchors.centerIn: parent
                            text: Icons.desktop
                            font.family: Theme.font.icon
                            font.pixelSize: 20
                            color: Theme.color.muted
                        }

                        // --- text entry ---
                        RowLayout {
                            visible: !row.modelData.isImage
                            anchors.fill: parent
                            anchors.leftMargin: Theme.gap.sm
                            anchors.rightMargin: Theme.gap.sm
                            spacing: Theme.gap.sm

                            Text {
                                text: Icons.clipboard
                                font.family: Theme.font.icon
                                font.pixelSize: 12
                                color: Theme.color.teal
                            }
                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.preview
                                color: Theme.color.fg
                                font.family: Theme.font.mono
                                font.pixelSize: Theme.font.sizeUi - 1
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            anchors { right: parent.right; top: parent.top; margins: 4 }
                            width: 20; height: 20; radius: 10
                            color: Qt.rgba(0.039, 0.047, 0.071, 0.75)
                            visible: rowMouse.containsMouse || !row.modelData.isImage

                            Text {
                                anchors.centerIn: parent
                                text: Icons.trash
                                font.family: Theme.font.icon
                                font.pixelSize: 10
                                color: Theme.color.fgDim
                            }
                            Ripple {
                                cornerRadius: 10
                                onClicked: root.deleteEntry(row.modelData.preview)
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            z: -1
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.copyEntry(row.modelData.id)
                        }
                    }
                    }
                }
            }

            // thin custom scrollbar — matches the hand-built widget language
            // used everywhere else rather than a stock control
            Rectangle {
                visible: flick.contentHeight > flick.height
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 4
                radius: 2
                color: Theme.color.surface

                Rectangle {
                    width: parent.width
                    radius: 2
                    color: Theme.color.accent
                    y: flick.visibleArea.yPosition * parent.height
                    height: Math.max(20, flick.visibleArea.heightRatio * parent.height)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Theme.radius.md
            color: "transparent"
            border.width: 1
            border.color: Theme.color.surface
            visible: root.entries.length > 0

            Text {
                anchors.centerIn: parent
                text: "Clear all"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi - 1
            }

            Ripple {
                cornerRadius: Theme.radius.md
                onClicked: root.wipeAll()
            }
        }
    }
}
