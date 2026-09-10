import QtQuick
import ".."

// A horizontal fill meter (volume, brightness, TDP headroom, ...).
Rectangle {
    id: root
    property real value: 0 // 0..1
    property color tint: Theme.color.accent

    width: 64
    height: 6
    radius: height / 2
    color: Theme.color.muted

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: parent.width * Math.max(0, Math.min(1, root.value))
        radius: parent.radius
        color: root.tint

        Behavior on width {
            NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic }
        }
    }
}
