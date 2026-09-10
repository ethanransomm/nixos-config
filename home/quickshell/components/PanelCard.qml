import QtQuick
import QtQuick.Layouts
import ".."

// Motif A: the drop-card every panel shares. Gradient header (bordered icon
// tile + live status dot) over a column of content rows.
Rectangle {
    id: root
    property string subtitle: ""
    property color subtitleColor: Theme.color.fgDim
    property string headerGlyph: ""
    property color statusColor: Theme.color.green
    default property alias content: contentColumn.data

    width: 360
    implicitHeight: header.height + contentColumn.implicitHeight + Theme.gap.lg * 2
    radius: Theme.radius.lg
    color: Theme.color.bgAlt
    border.width: 1
    border.color: Qt.rgba(0.14, 0.24, 0.25, 0.5)
    clip: true

    // Ambient glow orbs — the same soft-orb language the wallpaper and lock
    // screen already use, brought into the card so it reads as "alive"
    // rather than flat static chrome. Clipped to the card's rounded corners.
    Rectangle {
        width: 160; height: 160; radius: 80
        color: root.statusColor
        opacity: 0.07
        anchors { right: parent.right; top: parent.top; rightMargin: -60; topMargin: -70 }
    }
    Rectangle {
        width: 140; height: 140; radius: 70
        color: Theme.color.accent
        opacity: 0.05
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: -50; bottomMargin: -60 }
    }

    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        // The glyph in the icon tile already says what this panel is — no
        // separate name label needed, just the one live-status line.
        height: 56
        topLeftRadius: root.radius
        topRightRadius: root.radius
        bottomLeftRadius: 0
        bottomRightRadius: 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.color.bg }
            GradientStop { position: 1.0; color: "#1f1712" }
        }

        // Fades the header's identity-gradient into the body's own flat
        // color toward the bottom edge, so the two no longer meet as a hard
        // seam — the header dissolves into the content instead of sitting on
        // top of it as a separate block.
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(Theme.color.bgAlt.r, Theme.color.bgAlt.g, Theme.color.bgAlt.b, 0) }
                GradientStop { position: 1.0; color: Theme.color.bgAlt }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.gap.md
            anchors.rightMargin: Theme.gap.md
            spacing: Theme.gap.sm

            Item {
                // No boxed tile — a bordered square around one glyph read as
                // clunky no matter how subtle the fill/border got. Just the
                // glyph itself, bare, with a soft breathing glow behind it
                // and the status dot as the only remaining "container" cue.
                id: iconTile
                width: 34
                height: 34

                Rectangle {
                    anchors.centerIn: parent
                    width: 30; height: 30
                    radius: width / 2
                    color: Theme.color.accent
                    property real glowOp: 0.05
                    opacity: glowOp
                    SequentialAnimation on glowOp {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.05; to: 0.14; duration: 2000; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.14; to: 0.05; duration: 2000; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.headerGlyph
                    font.family: Theme.font.icon
                    font.pixelSize: 21
                    // Tinted by the same statusColor that drives the dot
                    // below it, instead of a flat stark-white glyph on every
                    // panel regardless of context — ties the icon into each
                    // panel's own accent rather than sitting on top of it.
                    color: root.statusColor
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }
                }

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.statusColor
                    anchors { right: parent.right; bottom: parent.bottom; rightMargin: -1; bottomMargin: -1 }
                    border.width: 1
                    border.color: Qt.rgba(Theme.color.bg.r, Theme.color.bg.g, Theme.color.bg.b, 0.6)
                }
            }

            Text {
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: root.subtitleColor
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi + 1
                font.weight: Font.Medium
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            topMargin: Theme.gap.lg
            leftMargin: Theme.gap.md
            rightMargin: Theme.gap.md
        }
        spacing: Theme.gap.md
    }
}
