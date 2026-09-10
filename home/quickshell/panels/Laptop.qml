import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "laptop"
    edge: "right"
    sideMargin: 60

    readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null

    readonly property var presetNames: ["Silent Beast", "Balanced", "Battery Saver", "Turbo"]
    // tailord profile IDs, seeded declaratively (see hosts/laptop/configuration.nix)
    readonly property var presetIds: ["silent_beast", "balanced", "battery_saver", "turbo"]
    readonly property var presetIcons: [Icons.moon, Icons.gear, Icons.battery, Icons.fan]
    readonly property var presetTints: [Theme.color.teal, Theme.color.accent, Theme.color.green, Theme.color.maroon]
    property string activeProfileId: ""
    readonly property int presetIndex: root.presetIds.indexOf(root.activeProfileId)

    // Mirrors the temp(°C)->fan(%) points baked into
    // hosts/laptop/configuration.nix's environment.etc block — kept as a
    // second copy here purely so the panel can draw what a curve looks like
    // without shelling out to read/parse JSON; there's no shared source
    // between Nix and QML, so if a curve is retuned, update both.
    readonly property var fanCurves: ({
        battery_saver: [ {temp:30,fan:0}, {temp:45,fan:15}, {temp:55,fan:25}, {temp:65,fan:35}, {temp:75,fan:50}, {temp:85,fan:70}, {temp:95,fan:100} ],
        balanced:      [ {temp:25,fan:0}, {temp:30,fan:10}, {temp:40,fan:22}, {temp:50,fan:35}, {temp:60,fan:45}, {temp:70,fan:62}, {temp:80,fan:75}, {temp:90,fan:100} ],
        silent_beast:  [ {temp:30,fan:0}, {temp:40,fan:8}, {temp:50,fan:18}, {temp:60,fan:30}, {temp:70,fan:45}, {temp:80,fan:65}, {temp:90,fan:100} ],
        turbo:         [ {temp:20,fan:20}, {temp:30,fan:35}, {temp:40,fan:45}, {temp:50,fan:55}, {temp:60,fan:70}, {temp:70,fan:85}, {temp:80,fan:100} ]
    })

    function refreshProfile() { profileListProc.running = true; }
    onOpenedChanged: if (opened) root.refreshProfile()
    Timer { interval: 3000; running: root.opened; repeat: true; onTriggered: root.refreshProfile() }

    Process {
        id: profileListProc
        command: ["tailor", "profile", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                // "battery_saver (active)" — one profile per line, at most one marked active
                for (const line of text.split("\n")) {
                    const trimmed = line.trim();
                    if (trimmed.endsWith("(active)")) {
                        root.activeProfileId = trimmed.replace("(active)", "").trim();
                        return;
                    }
                }
            }
        }
    }

    Process { id: setProfileProc; onExited: root.refreshProfile() }
    function setProfile(id) {
        setProfileProc.command = ["tailor", "profile", "set", id];
        setProfileProc.running = true;
    }

    // --- Keyboard backlight — direct sysfs, separate from tailord's own
    // (much more involved) per-device LED profile system. Permissions
    // widened for the `video` group via udev (see hosts/laptop/configuration.nix).
    readonly property string kbdLedPath: "/sys/class/leds/rgb:kbd_backlight"
    property int kbdBrightness: 0
    property string kbdColorLabel: ""
    property bool kbdRainbow: false
    property real kbdHue: 0

    readonly property var kbdSwatches: [
        { r: 255, g: 255, b: 255, label: "White" },
        { r: 255, g: 0, b: 0, label: "Red" },
        { r: 255, g: 140, b: 0, label: "Amber" },
        { r: 0, g: 200, b: 90, label: "Green" },
        { r: 78, g: 135, b: 144, label: "Teal" },
        { r: 140, g: 60, b: 220, label: "Violet" },
        { rainbow: true, label: "Rainbow" }
    ]

    function refreshKbdLed() { kbdBrightnessProc.running = true; }
    Component.onCompleted: root.refreshKbdLed()

    Process {
        id: kbdBrightnessProc
        command: ["cat", root.kbdLedPath + "/brightness"]
        stdout: StdioCollector {
            onStreamFinished: { const v = parseInt(text.trim()); if (!isNaN(v)) root.kbdBrightness = v; }
        }
    }

    // Explicit user actions (brightness drag, a swatch click) get their own
    // Process, kept entirely separate from the rainbow ticker below — sharing
    // one Process between a 3Hz timer and on-demand clicks meant a click
    // could land while a stale rainbow write was still in flight and get
    // silently dropped (Process ignores `running = true` while already
    // running), which is what made "White" sometimes fail to actually stop
    // the rainbow.
    Process { id: kbdWriteProc }
    function setKbdBrightness(pct) {
        const v = Math.round(Math.max(0, Math.min(1, pct)) * 255);
        root.kbdBrightness = v;
        kbdWriteProc.command = ["bash", "-c", "echo " + v + " > " + root.kbdLedPath + "/brightness"];
        kbdWriteProc.running = true;
    }
    function setKbdColor(r, g, b, label) {
        root.kbdRainbow = false;
        root.kbdColorLabel = label;
        const rgbStr = r + " " + g + " " + b;
        kbdWriteProc.command = ["bash", "-c",
            "echo '" + rgbStr + "' > " + root.kbdLedPath + "/multi_intensity" +
            (root.kbdBrightness === 0 ? "; echo 180 > " + root.kbdLedPath + "/brightness" : "")];
        kbdWriteProc.running = true;
        if (root.kbdBrightness === 0) root.kbdBrightness = 180;
    }
    function setKbdRainbow(enable) {
        root.kbdRainbow = enable;
        if (enable) {
            root.kbdColorLabel = "Rainbow";
            if (root.kbdBrightness === 0) root.setKbdBrightness(180 / 255);
        }
    }

    // Hue-cycle while Rainbow is active — runs independently of the panel
    // being open, like any other ambient effect toggle. This EC has no
    // hardware fade — every write is an instant hard switch — so ticking at
    // ~8Hz (the original interval) was firing a new color before the
    // previous one had even settled, which read as a flicker/strobe rather
    // than a sweep. Slower steps let each color actually display.
    Process { id: rainbowWriteProc }
    Timer {
        interval: 350
        running: root.kbdRainbow
        repeat: true
        onTriggered: {
            if (rainbowWriteProc.running) return; // don't queue up behind a slow write
            root.kbdHue = (root.kbdHue + 0.015) % 1.0;
            const c = Qt.hsva(root.kbdHue, 1.0, 1.0, 1.0);
            const r = Math.round(c.r * 255), g = Math.round(c.g * 255), b = Math.round(c.b * 255);
            rainbowWriteProc.command = ["bash", "-c", "echo '" + r + " " + g + " " + b + "' > " + root.kbdLedPath + "/multi_intensity"];
            rainbowWriteProc.running = true;
        }
    }

    PanelCard {
        width: 380
        subtitle: root.presetIndex >= 0 ? root.presetNames[root.presetIndex] : "Custom"
        headerGlyph: Icons.microchip
        statusColor: root.presetIndex >= 0 ? root.presetTints[root.presetIndex] : Theme.color.green

        // --- presets ---
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Theme.gap.sm
            columnSpacing: Theme.gap.sm

            Repeater {
                model: root.presetNames

                delegate: Rectangle {
                    id: tile
                    required property string modelData
                    required property int index
                    readonly property bool active: root.presetIndex === index
                    readonly property color accentTint: root.presetTints[index]

                    Layout.fillWidth: true
                    implicitHeight: 52
                    radius: Theme.radius.md
                    color: active ? Qt.rgba(accentTint.r, accentTint.g, accentTint.b, 0.14) : Theme.color.bg
                    border.width: active ? 1.5 : 0
                    border.color: accentTint
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }
                    Behavior on border.width { NumberAnimation { duration: Theme.animDuration } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.gap.sm
                        spacing: Theme.gap.sm

                        IconTile {
                            glyph: root.presetIcons[tile.index]
                            tint: tile.accentTint
                            size: 30
                            color: Qt.rgba(tile.accentTint.r, tile.accentTint.g, tile.accentTint.b, tile.active ? 0.28 : 0.16)
                        }

                        Text {
                            text: modelData
                            color: tile.active ? Theme.color.fgBright : Theme.color.fgDim
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi - 1
                            font.weight: tile.active ? Font.DemiBold : Font.Normal
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Ripple {
                        cornerRadius: Theme.radius.md
                        onClicked: root.setProfile(root.presetIds[tile.index])
                    }
                }
            }
        }

        // --- fan curve preview ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Fan curve"
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 1
                    Layout.fillWidth: true
                }
                Text {
                    text: root.presetIndex >= 0 ? root.presetNames[root.presetIndex] : "—"
                    color: Theme.color.fgDim
                    font.family: Theme.font.mono
                    font.pixelSize: Theme.font.sizeUi - 2
                }
            }

            Canvas {
                id: fanGraph
                Layout.fillWidth: true
                implicitHeight: 56

                readonly property var points: root.presetIndex >= 0
                    ? root.fanCurves[root.presetIds[root.presetIndex]] : null
                readonly property color tint: root.presetIndex >= 0
                    ? root.presetTints[root.presetIndex] : Theme.color.fgDim

                onPointsChanged: requestPaint()
                onTintChanged: requestPaint()
                Component.onCompleted: requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const pts = points;
                    if (!pts || pts.length === 0) return;

                    const minT = 15, maxT = 100, pad = 3;
                    const w = width - pad * 2, h = height - pad * 2;
                    const X = t => pad + (t - minT) / (maxT - minT) * w;
                    const Y = f => pad + h - (f / 100) * h;

                    ctx.strokeStyle = Theme.color.surface;
                    ctx.lineWidth = 1;
                    for (const frac of [0, 0.5, 1]) {
                        const y = pad + h * (1 - frac);
                        ctx.beginPath(); ctx.moveTo(pad, y); ctx.lineTo(width - pad, y); ctx.stroke();
                    }

                    ctx.beginPath();
                    ctx.moveTo(X(pts[0].temp), Y(0));
                    for (const p of pts) ctx.lineTo(X(p.temp), Y(p.fan));
                    ctx.lineTo(X(pts[pts.length - 1].temp), Y(0));
                    ctx.closePath();
                    ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, 0.15);
                    ctx.fill();

                    ctx.beginPath();
                    ctx.moveTo(X(pts[0].temp), Y(pts[0].fan));
                    for (const p of pts) ctx.lineTo(X(p.temp), Y(p.fan));
                    ctx.strokeStyle = tint;
                    ctx.lineWidth = 2;
                    ctx.lineJoin = "round";
                    ctx.stroke();
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.color.surface }

        IconRow {
            Layout.fillWidth: true
            glyph: Icons.microchip
            tint: Theme.color.green
            label: "CPU power"
            value: (SystemStats.currentWatts >= 0 ? Math.round(SystemStats.currentWatts) + " W" : "—") +
                   " / " + Math.round(SystemStats.limitWatts) + " W limit"
            LevelMeter {
                tint: Theme.color.green
                value: (SystemStats.limitWatts > 0 && SystemStats.currentWatts >= 0) ? Math.min(1, SystemStats.currentWatts / SystemStats.limitWatts) : 0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs

            IconRow {
                Layout.fillWidth: true
                glyph: Icons.sun
                tint: Theme.color.sand
                label: "Brightness"
                value: Math.round(SystemStats.brightnessPct * 100) + "%"
            }

            Rectangle {
                id: brightTrack
                Layout.fillWidth: true
                implicitHeight: 10
                radius: 5
                color: Theme.color.bg

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * SystemStats.brightnessPct
                    radius: parent.radius
                    color: Theme.color.sand
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: (mouse) => SystemStats.setBrightness(Math.max(0, Math.min(1, mouse.x / width)))
                    onPositionChanged: (mouse) => { if (pressed) SystemStats.setBrightness(Math.max(0, Math.min(1, mouse.x / width))); }
                }
            }
        }

        IconRow {
            Layout.fillWidth: true
            glyph: Icons.heart
            tint: Theme.color.green
            label: "Battery health"
            value: (root.battery && root.battery.healthSupported) ? Math.round(root.battery.healthPercentage) + "%" : "—"
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.color.surface }

        // --- Keyboard backlight ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.xs

            IconRow {
                Layout.fillWidth: true
                glyph: Icons.keyboard
                tint: Theme.color.teal
                label: "Keyboard backlight"
                value: Math.round(root.kbdBrightness / 255 * 100) + "%"
            }

            Rectangle {
                id: kbdTrack
                Layout.fillWidth: true
                implicitHeight: 10
                radius: 5
                color: Theme.color.bg

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * (root.kbdBrightness / 255)
                    radius: parent.radius
                    color: root.kbdRainbow ? Qt.hsva(root.kbdHue, 1.0, 1.0, 1.0) : Theme.color.teal
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: (mouse) => root.setKbdBrightness(mouse.x / width)
                    onPositionChanged: (mouse) => { if (pressed) root.setKbdBrightness(mouse.x / width); }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.gap.sm
                spacing: Theme.gap.md

                Repeater {
                    model: root.kbdSwatches

                    delegate: Item {
                        id: swatchItem
                        required property var modelData
                        readonly property bool isRainbow: !!modelData.rainbow
                        readonly property bool selected: root.kbdColorLabel === modelData.label &&
                            (isRainbow ? root.kbdRainbow : !root.kbdRainbow)

                        width: 30; height: 30

                        // ambient glow behind the selected swatch
                        Rectangle {
                            visible: swatchItem.selected
                            anchors.centerIn: parent
                            width: 42; height: 42; radius: 21
                            color: swatchItem.isRainbow ? Theme.color.fgBright
                                   : Qt.rgba(swatchItem.modelData.r / 255, swatchItem.modelData.g / 255, swatchItem.modelData.b / 255, 1)
                            opacity: 0.22
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            visible: !swatchItem.isRainbow
                            color: swatchItem.isRainbow ? "transparent"
                                   : Qt.rgba(swatchItem.modelData.r / 255, swatchItem.modelData.g / 255, swatchItem.modelData.b / 255, 1)
                            border.width: swatchItem.selected ? 2 : 1
                            border.color: swatchItem.selected ? Theme.color.fgBright : Theme.color.surface
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            visible: swatchItem.isRainbow
                            border.width: swatchItem.selected ? 2 : 1
                            border.color: swatchItem.selected ? Theme.color.fgBright : Theme.color.surface
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#ff0000" }
                                GradientStop { position: 0.17; color: "#ffff00" }
                                GradientStop { position: 0.34; color: "#00ff00" }
                                GradientStop { position: 0.5; color: "#00ffff" }
                                GradientStop { position: 0.67; color: "#0000ff" }
                                GradientStop { position: 0.84; color: "#ff00ff" }
                                GradientStop { position: 1.0; color: "#ff0000" }
                            }
                        }

                        Rectangle {
                            visible: swatchItem.selected
                            anchors { right: parent.right; bottom: parent.bottom; rightMargin: -2; bottomMargin: -2 }
                            width: 14; height: 14; radius: 7
                            color: Theme.color.bgAlt
                            border.width: 1
                            border.color: Theme.color.fgBright

                            Text {
                                anchors.centerIn: parent
                                text: Icons.check
                                font.family: Theme.font.icon
                                font.pixelSize: 8
                                color: Theme.color.fgBright
                            }
                        }

                        Ripple {
                            cornerRadius: 15
                            onClicked: swatchItem.isRainbow
                                ? root.setKbdRainbow(true)
                                : root.setKbdColor(swatchItem.modelData.r, swatchItem.modelData.g, swatchItem.modelData.b, swatchItem.modelData.label)
                        }
                    }
                }
            }
        }
    }
}
