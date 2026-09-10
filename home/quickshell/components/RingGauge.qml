import QtQuick
import ".."

// Circular progress ring — battery charge, clock dashboard sun-arc, etc.
Item {
    id: root
    property real value: 0 // 0..1
    property color tint: Theme.color.accent
    property color track: Theme.color.surface
    property real thickness: 6
    property real startAngle: -90 // degrees, 0 = 3 o'clock, -90 = 12 o'clock
    property real sweepAngle: 360
    // Opt-in extras (default off so Clock's sun-arc keeps its plain look) —
    // a soft ambient glow behind the ring, and a slow breathing pulse on it
    // for states worth calling out at a glance (e.g. actively charging).
    property bool glow: false
    property bool pulse: false
    default property alias content: centerSlot.data

    Behavior on value { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    Behavior on tint { ColorAnimation { duration: 300 } }

    QtObject {
        id: breathe
        property real op: 1.0
        SequentialAnimation on op {
            running: root.pulse
            loops: Animation.Infinite
            NumberAnimation { from: 0.55; to: 1.0; duration: 1400; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.0; to: 0.55; duration: 1400; easing.type: Easing.InOutSine }
        }
        onOpChanged: canvas.requestPaint()
    }

    Rectangle {
        visible: root.glow
        anchors.centerIn: parent
        width: parent.width + 24; height: width; radius: width / 2
        color: root.tint
        opacity: (root.pulse ? breathe.op : 1.0) * 0.1
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const cx = width / 2, cy = height / 2;
            const r = Math.min(width, height) / 2 - root.thickness / 2;
            const start = root.startAngle * Math.PI / 180;
            const sweep = root.sweepAngle * Math.PI / 180;

            ctx.lineWidth = root.thickness;
            ctx.lineCap = "round";

            ctx.strokeStyle = root.track;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + sweep);
            ctx.stroke();

            const t = root.tint;
            ctx.strokeStyle = root.pulse ? Qt.rgba(t.r, t.g, t.b, 0.6 + breathe.op * 0.4) : t;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + sweep * Math.max(0, Math.min(1, root.value)));
            ctx.stroke();
        }
    }

    onValueChanged: canvas.requestPaint()
    onTintChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()

    Item {
        id: centerSlot
        anchors.centerIn: parent
    }
}
