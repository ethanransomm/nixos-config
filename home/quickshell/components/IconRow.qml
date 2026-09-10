import QtQuick
import QtQuick.Layouts
import ".."

// One content row inside a panel: coloured icon tile, label left, value/viz
// right. Extra children (a SignalBars, LevelMeter, etc.) land in the trailing
// slot via the default property.
RowLayout {
    id: root
    property string glyph: ""
    property color tint: Theme.color.fg
    property string label: ""
    property string value: ""
    default property alias trailing: trailingSlot.data

    Layout.fillWidth: true
    spacing: Theme.gap.sm

    IconTile {
        glyph: root.glyph
        tint: root.tint
    }

    Text {
        text: root.label
        color: Theme.color.fg
        font.family: Theme.font.sans
        font.pixelSize: Theme.font.sizeUi
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    Text {
        visible: root.value.length > 0
        text: root.value
        color: Theme.color.fgDim
        font.family: Theme.font.mono
        font.pixelSize: Theme.font.sizeUi
    }

    RowLayout {
        id: trailingSlot
        spacing: Theme.gap.xs
    }
}
