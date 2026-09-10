import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import ".."

// The reusable Motif-A popup: a fullscreen click-catching overlay with the
// actual card anchored under its triggering pill. Panels toggle `opened`.
PanelWindow {
    id: root
    property string panelName: ""
    property bool opened: PanelState.openPanel === root.panelName
    property string edge: "right" // "left" | "right" | "center" | "float" (centered on screen)
    property int sideMargin: 16
    // Bar is 44px tall, flush to the screen top (see modules/Bar.qml) — clear
    // it with a small gap so panels never overlap it.
    property int topGap: 52
    default property alias content: cardSlot.data

    visible: opened
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors { top: true; left: true; right: true; bottom: true }

    Rectangle {
        anchors.fill: parent
        visible: root.edge === "float"
        color: Qt.rgba(0.063, 0.078, 0.122, 0.7)
        opacity: root.opened ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animDuration } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: PanelState.close()
    }

    Item {
        id: cardAnchor
        // The bar reports each pill's real screen-space centre X (see
        // components/BarIconValue.qml) — use it to drop exactly under the
        // pill that was clicked instead of a guessed static margin.
        readonly property var capturedX: PanelState.pillX[root.panelName]
        readonly property bool useCapture: (root.edge === "left" || root.edge === "right") && capturedX !== undefined
        width: cardSlot.childrenRect.width
        height: cardSlot.childrenRect.height

        anchors.centerIn: root.edge === "float" ? parent : undefined
        anchors.top: root.edge === "float" ? undefined : parent.top
        anchors.topMargin: root.edge === "float" ? 0 : root.topGap
        anchors.left: root.edge === "left" ? parent.left : undefined
        anchors.leftMargin: root.edge === "left" ? root.sideMargin : 0
        anchors.right: root.edge === "right" ? parent.right : undefined
        anchors.rightMargin: root.edge === "right" ? root.sideMargin : 0
        anchors.horizontalCenter: root.edge === "center" ? parent.horizontalCenter : undefined

        // Once the bar reports a real pill position, override x directly —
        // deliberately outside the anchors{} group (a margin binding that
        // reads this item's own width trips QML's anchor loop detector even
        // without a real cycle). Binding's default restoreMode puts the
        // anchor-driven x back if `when` ever turns false.
        Binding {
            target: cardAnchor
            property: "x"
            when: cardAnchor.useCapture
            value: Math.max(16, Math.min(cardAnchor.capturedX - cardAnchor.width / 2,
                                          root.width - cardAnchor.width - 16))
        }

        scale: root.opened ? 1 : 0.96
        opacity: root.opened ? 1 : 0
        Behavior on scale { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.animDuration; easing.type: Easing.OutCubic } }

        MouseArea {
            // swallows clicks on the card so they don't fall through to the close-area
            anchors.fill: parent
        }

        // Soft floating-card shadow — cards sat flat against the wallpaper
        // with nothing but a 1px border before this.
        MultiEffect {
            anchors.fill: cardSlot
            source: cardSlot
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.55)
            shadowBlur: 0.6
            shadowVerticalOffset: 10
            shadowHorizontalOffset: 0
        }

        Item {
            id: cardSlot
        }
    }
}
