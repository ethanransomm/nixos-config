import QtQuick
import ".."

// A coloured-stroke icon tile — colour lives in the glyph, not a filled bg,
// per the brief's icon discipline (bare coloured-stroke over filled tiles).
Rectangle {
    id: root
    property string glyph: ""
    property color tint: Theme.color.fg
    property int size: 30
    property real glyphScale: 0.5

    width: size
    height: size
    radius: Theme.radius.sm
    color: Theme.color.surface

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.tint
        font.family: Theme.font.icon
        font.pixelSize: root.size * root.glyphScale
    }
}
