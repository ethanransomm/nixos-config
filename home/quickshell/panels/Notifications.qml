import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import ".."
import "../components"

DropPanel {
    id: root
    panelName: "notifications"
    edge: "right"
    sideMargin: 60

    function urgencyColor(u) {
        if (u === NotificationUrgency.Critical) return Theme.color.accent;
        if (u === NotificationUrgency.Low) return Theme.color.teal;
        return Theme.color.sand;
    }

    // Group flat notification list by appName, preserving most-recent-first order.
    readonly property var grouped: {
        const groups = [];
        const byApp = {};
        const list = NotifStore.notifications.values;
        for (let i = list.length - 1; i >= 0; i--) {
            const n = list[i];
            const key = n.appName || "unknown";
            if (!byApp[key]) {
                byApp[key] = { appName: key, items: [] };
                groups.push(byApp[key]);
            }
            byApp[key].items.push(n);
        }
        return groups;
    }

    PanelCard {
        width: 380
        subtitle: NotifStore.notifications.values.length + " new"
        headerGlyph: Icons.bell
        statusColor: NotifStore.dndEnabled ? Theme.color.fgDim : Theme.color.green

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Do not disturb"
                color: Theme.color.fg
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: 40
                implicitHeight: 22

                Rectangle {
                    visible: NotifStore.dndEnabled
                    anchors.centerIn: parent
                    width: parent.width + 14; height: parent.height + 14; radius: height / 2
                    color: Theme.color.accent
                    opacity: 0.18
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 11
                    color: NotifStore.dndEnabled ? Theme.color.accent : Theme.color.muted
                    Behavior on color { ColorAnimation { duration: Theme.animDuration } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: Theme.color.fgBright
                        anchors.verticalCenter: parent.verticalCenter
                        x: NotifStore.dndEnabled ? parent.width - width - 2 : 2
                        Behavior on x { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }
                    }

                    Ripple {
                        cornerRadius: 11
                        onClicked: NotifStore.dndEnabled = !NotifStore.dndEnabled
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.color.surface }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.md
            visible: root.grouped.length === 0

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "No notifications"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gap.md

            Repeater {
                model: root.grouped

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: Theme.gap.xs

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.gap.xs
                        Text {
                            text: modelData.appName
                            color: Theme.color.fgDim
                            font.family: Theme.font.sans
                            font.pixelSize: Theme.font.sizeUi - 1
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Icons.close
                            font.family: Theme.font.icon
                            font.pixelSize: 11
                            color: Theme.color.fgDim
                            Ripple {
                                anchors.margins: -6
                                cornerRadius: height / 2
                                onClicked: { for (const n of modelData.items) n.dismiss(); }
                            }
                        }
                    }

                    Repeater {
                        model: modelData.items

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: card.implicitHeight + Theme.gap.sm * 2
                            radius: Theme.radius.md
                            color: Theme.color.bg
                            border.width: 0

                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width: 3
                                radius: 1.5
                                color: root.urgencyColor(modelData.urgency)
                            }

                            ColumnLayout {
                                id: card
                                anchors {
                                    left: parent.left; right: parent.right; top: parent.top
                                    leftMargin: Theme.gap.sm + 4; rightMargin: Theme.gap.sm; topMargin: Theme.gap.sm
                                }
                                spacing: 2

                                Text {
                                    text: modelData.summary
                                    color: Theme.color.fgBright
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.sizeUi
                                    font.weight: Font.Medium
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: modelData.body.length > 0
                                    text: modelData.body
                                    color: Theme.color.fgDim
                                    font.family: Theme.font.sans
                                    font.pixelSize: Theme.font.sizeUi - 1
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Theme.gap.xs
                                    visible: modelData.actions.length > 0

                                    Repeater {
                                        model: modelData.actions
                                        delegate: Rectangle {
                                            required property var modelData
                                            implicitWidth: actionLabel.implicitWidth + 16
                                            implicitHeight: 22
                                            radius: Theme.radius.sm
                                            color: index === 0 ? Theme.color.accent : "transparent"
                                            border.width: index === 0 ? 0 : 1
                                            border.color: Theme.color.surface

                                            Text {
                                                id: actionLabel
                                                anchors.centerIn: parent
                                                text: modelData.text
                                                color: index === 0 ? Theme.color.fgBright : Theme.color.fgDim
                                                font.family: Theme.font.sans
                                                font.pixelSize: Theme.font.sizeUi - 2
                                            }

                                            Ripple {
                                                cornerRadius: Theme.radius.sm
                                                onClicked: modelData.invoke()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Theme.radius.md
            color: "transparent"
            border.width: 1
            border.color: Theme.color.surface
            visible: root.grouped.length > 0

            Text {
                anchors.centerIn: parent
                text: "Clear all"
                color: Theme.color.fgDim
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi
            }

            Ripple {
                cornerRadius: Theme.radius.md
                onClicked: NotifStore.dismissAll()
            }
        }
    }
}
