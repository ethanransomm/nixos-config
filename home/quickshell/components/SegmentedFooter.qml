import QtQuick
import QtQuick.Layouts
import ".."

// Icon-led segmented footer — mode switches between sibling panels
// (Wi-Fi/Bluetooth/Wired, etc.).
Rectangle {
    id: root
    property var segments: [] // [{ glyph, label, active }]
    signal segmentClicked(int index)

    Layout.fillWidth: true
    implicitHeight: 36
    radius: Theme.radius.md
    color: Theme.color.bg

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Repeater {
            model: root.segments

            delegate: Rectangle {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radius.sm
                color: modelData.active ? Theme.color.accentDeep : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.gap.xs

                    Text {
                        text: modelData.glyph
                        font.family: Theme.font.icon
                        font.pixelSize: Theme.font.sizeUi + 2
                        color: modelData.active ? Theme.color.fgBright : Theme.color.fgDim
                    }
                    Text {
                        text: modelData.label
                        font.family: Theme.font.sans
                        font.pixelSize: Theme.font.sizeUi
                        color: modelData.active ? Theme.color.fgBright : Theme.color.fgDim
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.segmentClicked(index)
                }
            }
        }
    }
}
