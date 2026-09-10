pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

// The single NotificationServer instance for the whole shell — Quickshell IS
// the notification daemon (swaync is disabled). Bar badge, standalone
// Notification Centre, and the Battery panel sidebar all read this.
QtObject {
    id: root

    property bool dndEnabled: false

    readonly property NotificationServer server: NotificationServer {
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true

        onNotification: (notification) => {
            notification.tracked = true;
        }
    }

    readonly property var notifications: server.trackedNotifications

    function dismissAll() {
        for (const n of notifications.values) n.dismiss();
    }
}
