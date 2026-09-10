import QtQuick
import QtQuick.Layouts
import ".."

// Small labeled fact tile — used in pairs (BAND / SECURITY, etc.) where a
// full IconRow would be overkill for a short static value.
Rectangle {
    id: root
    property string label: ""
    property string glyph: ""
    property color tint: Theme.color.fg
    property string value: ""

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + Theme.gap.sm * 2
    radius: Theme.radius.md
    color: Theme.color.bg

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Theme.gap.sm
        spacing: 3

        Text {
            text: root.label
            color: Theme.color.fgDim
            font.family: Theme.font.sans
            font.pixelSize: Theme.font.sizeUi - 4
            font.letterSpacing: 0.5
        }
        RowLayout {
            spacing: 5
            Text {
                text: root.glyph
                font.family: Theme.font.icon
                font.pixelSize: 12
                color: root.tint
            }
            Text {
                text: root.value
                color: Theme.color.fg
                font.family: Theme.font.sans
                font.pixelSize: Theme.font.sizeUi - 1
            }
        }
    }
}
