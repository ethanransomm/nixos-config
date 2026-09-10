pragma Singleton
import QtQuick

// Named glyph codepoints (Font Awesome subset of Nerd Fonts, all BMP code
// points) so icon choices live in one place and never depend on typing exotic
// Unicode literals into source files.
QtObject {
    function ch(code) { return String.fromCodePoint(code); }

    readonly property string nixos: ch(0xf313)
    readonly property string wifi: ch(0xf1eb)
    readonly property string bluetooth: ch(0xf293)
    readonly property string bluetoothB: ch(0xf294)
    readonly property string volumeUp: ch(0xf028)
    readonly property string volumeMute: ch(0xf026)
    readonly property string battery: ch(0xf240)
    readonly property string batteryHalf: ch(0xf242)
    readonly property string plug: ch(0xf1e6)
    readonly property string bell: ch(0xf0f3)
    readonly property string power: ch(0xf011)
    readonly property string gear: ch(0xf013)
    readonly property string clock: ch(0xf017)
    readonly property string microchip: ch(0xf2db)
    readonly property string laptop: ch(0xf109)
    readonly property string music: ch(0xf001)
    readonly property string sun: ch(0xf185)
    readonly property string moon: ch(0xf186)
    readonly property string cloud: ch(0xf0c2)
    readonly property string lock: ch(0xf023)
    readonly property string unlock: ch(0xf09c)
    readonly property string user: ch(0xf007)
    readonly property string signal: ch(0xf012)
    readonly property string shield: ch(0xf132)
    readonly property string refresh: ch(0xf021)
    readonly property string check: ch(0xf00c)
    readonly property string close: ch(0xf00d)
    readonly property string caretDown: ch(0xf0d7)
    readonly property string caretUp: ch(0xf0d8)
    readonly property string caretLeft: ch(0xf0d9)
    readonly property string caretRight: ch(0xf0da)
    readonly property string play: ch(0xf04b)
    readonly property string pause: ch(0xf04c)
    readonly property string next: ch(0xf051)
    readonly property string prev: ch(0xf048)
    readonly property string coffee: ch(0xf0f4)
    readonly property string desktop: ch(0xf108)
    readonly property string exchange: ch(0xf0ec)
    readonly property string thermometer: ch(0xf2c9)
    readonly property string fan: ch(0xf0210)
    readonly property string heart: ch(0xf004)
    readonly property string wind: ch(0xf0c2) // reuses the cloud glyph — no verified wind glyph in this font
    readonly property string tint: ch(0xf043)
    readonly property string clipboard: ch(0xf0ea)
    readonly property string trash: ch(0xf1f8)
    readonly property string search: ch(0xf002)
    readonly property string grid: ch(0xf00a)
    readonly property string window: ch(0xf2d0)
    readonly property string keyboard: ch(0xf11c)
}
