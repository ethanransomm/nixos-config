import QtQuick
import ".."

// Minimal signal-strength micro-viz — 4 bars of increasing height, lit up to
// `level` (0-4) in `tint`, the rest dim. Used by Wi-Fi/Bluetooth rows instead
// of a bare percentage.
Row {
    id: root
    property int level: 0
    property color tint: Theme.color.sand
    spacing: 2

    Repeater {
        model: 4
        Rectangle {
            width: 3
            radius: 1
            height: 6 + index * 3
            y: root.height - height
            color: index < root.level ? root.tint : Theme.color.muted
            opacity: index < root.level ? 1 : 0.4
        }
    }
}
