import QtQuick
import ".."

// Decorative smooth curved "equalizer" driven by playback state — NOT a real
// spectrum analyzer (no audio tap wired up), just a bit of characterful
// motion so the Media panel doesn't sit static while something plays.
Item {
    id: root
    property bool playing: false
    property int preset: 0 // 0 Calm, 1 Wave, 2 Pulse

    readonly property var presetCfg: [
        { amp: 6, freq: 1.4, speed: 0.035, color: Theme.color.teal },
        { amp: 11, freq: 2.2, speed: 0.06, color: Theme.color.sand },
        { amp: 16, freq: 3.1, speed: 0.09, color: Theme.color.accent }
    ][Math.max(0, Math.min(2, preset))]

    property real phase: 0

    Timer {
        interval: 33
        running: root.playing
        repeat: true
        onTriggered: {
            root.phase += root.presetCfg.speed;
            canvas.requestPaint();
        }
    }

    onPlayingChanged: canvas.requestPaint()
    onPresetChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const w = width, h = height, midY = h / 2;
            const cfg = root.presetCfg;
            const points = 24;

            ctx.beginPath();
            for (let i = 0; i <= points; i++) {
                const x = (w / points) * i;
                const amp = root.playing ? cfg.amp : 2;
                const y = midY + Math.sin(root.phase + i * cfg.freq * 0.4) * amp * Math.sin(i / points * Math.PI);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }

            ctx.strokeStyle = cfg.color;
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.stroke();

            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            const gradient = ctx.createLinearGradient(0, 0, 0, h);
            gradient.addColorStop(0, Qt.rgba(cfg.color.r, cfg.color.g, cfg.color.b, 0.25));
            gradient.addColorStop(1, Qt.rgba(cfg.color.r, cfg.color.g, cfg.color.b, 0));
            ctx.fillStyle = gradient;
            ctx.fill();
        }
    }

    Component.onCompleted: canvas.requestPaint()
}
