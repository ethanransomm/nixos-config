import QtQuick
import QtQuick.Layouts
import ".."

// Bar-pill affordance: icon + optional live value, click-through to a panel.
// A plain Item (not a Layout) so the MouseArea can safely anchor.fill it
// while still sizing correctly inside a parent RowLayout.
Item {
    id: root
    property string glyph: ""
    property color tint: Theme.color.fg
    property string value: ""
    // When set, this icon's screen-space centre X is continuously reported
    // to PanelState so panelName's DropPanel can drop exactly under it.
    property string panelName: ""
    signal clicked()

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    function reportPosition() {
        if (root.panelName.length > 0 && root.width > 0) {
            PanelState.reportPillX(root.panelName, root.mapToGlobal(root.width / 2, 0).x);
        }
    }

    onXChanged: reportPosition()
    onWidthChanged: reportPosition()
    Component.onCompleted: reportPosition()
    Timer { interval: 300; running: true; onTriggered: root.reportPosition() }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.glyph
            font.family: Theme.font.icon
            font.pixelSize: 15
            color: root.tint
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            font.family: Theme.font.mono
            font.pixelSize: Theme.font.sizeUi - 1
            color: Theme.color.fgDim
        }
    }

    Ripple {
        anchors.margins: -7
        cornerRadius: height / 2
        onClicked: root.clicked()
    }
}
