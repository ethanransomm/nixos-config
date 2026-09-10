pragma Singleton
import QtQuick
import Quickshell.Io

// Shared wttr.in poll — the bar's clock capsule and the Clock dashboard panel
// both read this instead of hitting the network twice.
QtObject {
    id: root

    property string tempC: "--"
    property string condition: ""
    property int humidity: 0
    property real windKmph: 0
    property string sunrise: ""
    property string sunset: ""

    property Timer pollTimer: Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }

    property Process proc: Process {
        command: ["curl", "-s", "--max-time", "8", "wttr.in/?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const cur = d.current_condition[0];
                    const astro = d.weather[0].astronomy[0];
                    root.tempC = cur.temp_C;
                    root.condition = cur.weatherDesc[0].value;
                    root.humidity = parseInt(cur.humidity);
                    root.windKmph = parseFloat(cur.windspeedKmph);
                    root.sunrise = astro.sunrise;
                    root.sunset = astro.sunset;
                } catch (e) {
                    // stale data is fine — just skip this cycle
                }
            }
        }
    }
}
