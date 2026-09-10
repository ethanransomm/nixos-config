import QtQuick
import ".."

// Simplified Material-style click feedback — adapted from caelestia-dots/
// shell's StateLayer (theirs draws an exact rounded-rect-clipped path via
// QtQuick.Shapes; this trades that precision for a plain circle clipped by
// a rounded Item, which reads the same at bar/panel pill sizes for a
// fraction of the complexity). Hover tint + an expanding ripple from the
// press point, instead of the flat instant color swaps used everywhere
// before this.
Item {
    id: root
    anchors.fill: parent
    property color rippleColor: Theme.color.fgBright
    property real hoverOpacity: 0.08
    property real cornerRadius: 0
    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.rippleColor
        opacity: mouse.containsMouse && !mouse.pressed ? root.hoverOpacity : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Item {
        anchors.fill: parent
        clip: true

        Rectangle {
            id: rippleCircle
            readonly property real d: Math.max(root.width, root.height) * 2.2
            width: d
            height: d
            radius: d / 2
            color: root.rippleColor
            opacity: 0
            scale: 0
            transformOrigin: Item.Center

            function playAt(px, py) {
                x = px - width / 2;
                y = py - height / 2;
                scale = 0;
                opacity = 0.22;
                scaleAnim.restart();
                fadeAnim.restart();
            }

            NumberAnimation {
                id: scaleAnim
                target: rippleCircle
                property: "scale"
                to: 1
                duration: 450
                easing.type: Easing.OutCubic
            }
            SequentialAnimation {
                id: fadeAnim
                PauseAnimation { duration: 150 }
                NumberAnimation { target: rippleCircle; property: "opacity"; to: 0; duration: 300 }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: (e) => rippleCircle.playAt(e.x, e.y)
        onClicked: root.clicked()
    }
}
