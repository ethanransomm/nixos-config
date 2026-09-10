import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "battery"
    edge: "right"
    sideMargin: 60

    readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null

    function fmtTime(seconds) {
        if (!seconds || seconds <= 0) return "—";
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    function powerAction(cmd) {
        actionProc.command = cmd;
        actionProc.running = true;
    }
    Process { id: actionProc }

    PanelCard {
        width: 460
        subtitle: root.battery
                  ? (root.battery.state === UPowerDeviceState.Charging ? "Charging" : "On battery")
                  : ""
        subtitleColor: root.battery && root.battery.state === UPowerDeviceState.Charging ? Theme.color.sand : Theme.color.fgDim
        headerGlyph: Icons.battery
        statusColor: root.battery && root.battery.state === UPowerDeviceState.Charging ? Theme.color.sand : Theme.color.green

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.lg

            // --- LEFT: notification sidebar (mirrors the Notification Centre) ---
            ColumnLayout {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                spacing: Theme.gap.xs

                Text {
                    text: "Notifications"
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 1
                }

                Text {
                    visible: NotifStore.notifications.values.length === 0
                    text: "Nothing new"
                    color: Theme.color.fgDim
                    font.family: Theme.font.sans
                    font.pixelSize: Theme.font.sizeUi - 1
                    font.italic: true
                }

                Repeater {
                    model: NotifStore.notifications.values.slice(-6).reverse()

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: sideCol.implicitHeight + Theme.gap.xs * 2
                        radius: Theme.radius.sm
                        color: Theme.color.bg

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            width: 2
                            color: modelData.urgency === NotificationUrgency.Critical ? Theme.color.accent : Theme.color.teal
                        }

                        ColumnLayout {
                            id: sideCol
                            anchors { fill: parent; margins: Theme.gap.xs; leftMargin: Theme.gap.xs + 4 }
                            spacing: 0
                            Text {
                                text: modelData.summary
                                color: Theme.color.fg
                                font.family: Theme.font.sans
                                font.pixelSize: Theme.font.sizeUi - 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: Theme.color.surface }

            // --- RIGHT: charge ring + power grid ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.gap.md

                RingGauge {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120
                    height: 120
                    value: root.battery ? root.battery.percentage : 0
                    tint: root.battery && root.battery.percentage < 0.2 ? Theme.color.maroon : Theme.color.accent
                    glow: true
                    pulse: root.battery && root.battery.state === UPowerDeviceState.Charging

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.battery ? Math.round(root.battery.percentage * 100) + "%" : "—"
                            color: Theme.color.fgBright
                            font.family: Theme.font.mono
                            font.pixelSize: 22
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.battery
                                  ? (root.battery.state === UPowerDeviceState.Charging
                                     ? root.fmtTime(root.battery.timeToFull) + " to full"
                                     : root.fmtTime(root.battery.timeToEmpty) + " left")
                                  : ""
                            color: Theme.color.fgDim
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi - 2
                        }
                    }
                }

                IconRow {
                    Layout.fillWidth: true
                    glyph: Icons.heart
                    tint: Theme.color.green
                    label: "Health"
                    value: (root.battery && root.battery.healthSupported) ? Math.round(root.battery.healthPercentage) + "%" : "—"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Theme.gap.sm
                    columnSpacing: Theme.gap.sm

                    Repeater {
                        model: [
                            { glyph: Icons.lock, label: "Lock", tint: Theme.color.accent, cmd: ["hyprlock"] },
                            { glyph: Icons.moon, label: "Sleep", tint: Theme.color.teal, cmd: ["systemctl", "suspend"] },
                            { glyph: Icons.refresh, label: "Restart", tint: Theme.color.sand, cmd: ["systemctl", "reboot"] },
                            { glyph: Icons.power, label: "Shut down", tint: Theme.color.maroon, cmd: ["systemctl", "poweroff"] },
                            { glyph: Icons.close, label: "Log out", tint: Theme.color.fgDim, cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] }
                        ]

                        delegate: Rectangle {
                            id: actionTile
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: Theme.radius.md
                            color: Theme.color.bg

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Theme.gap.xs
                                IconTile {
                                    glyph: actionTile.modelData.glyph
                                    tint: actionTile.modelData.tint
                                    size: 24
                                    color: Qt.rgba(actionTile.modelData.tint.r, actionTile.modelData.tint.g, actionTile.modelData.tint.b, 0.16)
                                }
                                Text {
                                    text: actionTile.modelData.label
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.sizeUi
                                    color: Theme.color.fg
                                }
                            }

                            Ripple {
                                cornerRadius: Theme.radius.md
                                onClicked: root.powerAction(actionTile.modelData.cmd)
                            }
                        }
                    }
                }
            }
        }
    }
}
