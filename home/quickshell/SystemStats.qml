pragma Singleton
import QtQuick
import Quickshell.Io

// Shared RAPL/brightness polling — read by both the bar's SystemCapsule and
// the Laptop panel, so we only run one poller instead of one per consumer.
QtObject {
    id: root

    readonly property string raplBase: "/sys/class/powercap/intel-rapl:0"

    property real currentWatts: -1 // -1 = unavailable (needs the RAPL udev rule)
    property real limitWatts: 0
    property real brightnessPct: 1

    property Timer raplTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.raplProc.running = true
    }

    property Process raplProc: Process {
        command: ["bash", "-c",
            "e1=$(cat " + root.raplBase + "/energy_uj 2>/dev/null); " +
            "sleep 0.4; " +
            "e2=$(cat " + root.raplBase + "/energy_uj 2>/dev/null); " +
            "lim=$(cat " + root.raplBase + "/constraint_0_power_limit_uw 2>/dev/null); " +
            "echo \"e1=$e1\"; echo \"e2=$e2\"; echo \"lim=$lim\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const values = {};
                for (const line of text.trim().split("\n")) {
                    const [key, val] = line.split("=");
                    if (val !== undefined && val.length > 0) values[key] = Number(val);
                }
                if (values.lim !== undefined) root.limitWatts = values.lim / 1e6;
                if (values.e1 !== undefined && values.e2 !== undefined) {
                    root.currentWatts = Math.max(0, (values.e2 - values.e1) / 1e6 / 0.4);
                } else {
                    root.currentWatts = -1;
                }
            }
        }
    }

    property Timer brightnessTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.brightnessPctProc.running = true
    }

    property Process brightnessPctProc: Process {
        command: ["bash", "-c", "brightnessctl -m i | head -1 | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim());
                if (!isNaN(v)) root.brightnessPct = v / 100;
            }
        }
    }

    property Process setBrightnessProc: Process { command: ["true"] }

    function setBrightness(pct) {
        root.brightnessPct = pct;
        setBrightnessProc.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"];
        setBrightnessProc.running = true;
    }
}
