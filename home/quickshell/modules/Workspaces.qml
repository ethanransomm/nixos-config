import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../components"

// Non-expanding per the brief — the only bar pill that doesn't open a panel.
Rectangle {
    id: root
    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + Theme.gap.sm * 2
    radius: Theme.radius.pill
    color: Theme.color.bgAlt
    border.width: 1
    border.color: Theme.color.surface

    // Hyprland.workspaces is a live object-model in creation order, not
    // numeric order — re-sort into a plain array on a cheap poll so the
    // pill reads left-to-right by number. Per-delegate active/urgent state
    // stays instantly live since delegates bind to the same objects.
    property var sorted: []
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sorted = [...Hyprland.workspaces.values].sort((a, b) => Number(a.name) - Number(b.name))
    }

    // Sliding active-workspace pill — adapted from caelestia-dots/shell's
    // ActiveIndicator: instead of the active workspace just instantly
    // swapping colour, one pill lives outside the row and animates its x/
    // width to whichever workspace is focused, so switching reads as a
    // single continuous motion rather than a cut. Sits behind the row (see
    // z below) so each workspace's own number stays on top of it.
    readonly property int activeIndex: root.sorted.findIndex(w => w.active)
    Rectangle {
        id: activePill
        z: 1
        radius: 13
        visible: root.activeIndex >= 0 && wsRepeater.count > root.activeIndex
        color: Theme.color.accent
        readonly property var activeItem: visible ? wsRepeater.itemAt(root.activeIndex) : null
        x: activeItem ? row.x + activeItem.x : 0
        y: activeItem ? row.y + activeItem.y : 0
        width: activeItem ? activeItem.width : 0
        height: activeItem ? activeItem.height : 0

        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    RowLayout {
        id: row
        z: 2
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            id: wsRepeater
            model: root.sorted

            delegate: Item {
                required property var modelData
                // "has windows but isn't focused" used to look identical to
                // "empty" (both just dim-muted) — give it its own state so
                // the pill actually tells you something at a glance.
                readonly property bool occupied: Hyprland.toplevels.values.some(t => t.workspace === modelData)
                width: 26
                height: 26

                Rectangle {
                    // occupied/urgent backdrop — hidden while active, since
                    // the sliding activePill covers that case instead
                    anchors.fill: parent
                    radius: 13
                    visible: !modelData.active
                    color: modelData.urgent ? Theme.color.maroon
                           : occupied ? Theme.color.surface
                           : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: (modelData.active || modelData.urgent) ? Theme.color.fgBright
                           : occupied ? Theme.color.fgDim
                           : Theme.color.muted
                    font.family: Theme.font.mono
                    font.pixelSize: 11
                }

                Ripple {
                    cornerRadius: 13
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.name + " })")
                }
            }
        }
    }
}
