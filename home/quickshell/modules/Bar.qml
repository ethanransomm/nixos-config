import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"

PanelWindow {
    id: root
    property bool caffeineOn: false

    readonly property int barHeight: 44

    anchors { top: true; left: true; right: true }
    implicitHeight: barHeight
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "ember-bar"
    exclusiveZone: barHeight

    IdleInhibitor {
        window: root
        enabled: root.caffeineOn
    }

    Process {
        id: launcherProc
        command: ["rofi", "-show", "drun"]
    }

    // Flush, edge-to-edge dock — no floating margins, no background showing
    // around the perimeter. Individual pills inside still carry the rounded
    // capsule language. Subtle vertical gradient (navy shifting to a warm
    // ember hint at the bottom edge) echoes the same gradient-header motif
    // every panel already uses, instead of a flat fill.
    Rectangle {
        id: barBg
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0.086, 0.11, 0.169, 0.94) }
            GradientStop { position: 1.0; color: Qt.rgba(0.122, 0.09, 0.078, 0.94) }
        }

        Rectangle {
            // thin warm accent line instead of the old floating underglow
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: Qt.rgba(0.76, 0.29, 0.12, 0.35)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.gap.sm
            anchors.rightMargin: Theme.gap.md
            spacing: Theme.gap.md

            // === LEFT: launcher + workspaces ===
            RowLayout {
                Layout.fillHeight: true
                spacing: Theme.gap.sm

                Rectangle {
                    Layout.fillHeight: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    implicitWidth: height
                    radius: Theme.radius.pill
                    color: Theme.color.surface
                    border.width: 1
                    border.color: Theme.color.accent

                    Text {
                        anchors.centerIn: parent
                        text: Icons.nixos
                        font.family: Theme.font.icon
                        font.pixelSize: 17
                        color: Theme.color.fgBright
                    }

                    Ripple {
                        cornerRadius: Theme.radius.pill
                        onClicked: launcherProc.running = true
                    }
                }

                Workspaces {
                    Layout.fillHeight: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }
            }

            // === CENTRE: clock + weather ===
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ClockCapsule {
                    anchors.centerIn: parent
                }
            }

            // === RIGHT: capsules ===
            RowLayout {
                Layout.fillHeight: true
                spacing: Theme.gap.sm

                MediaCapsule {
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    caffeineOn: root.caffeineOn
                    onToggleCaffeine: root.caffeineOn = !root.caffeineOn
                }

                ConnectivityCapsule {
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }

                SystemCapsule {
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }
            }
        }
    }
}
