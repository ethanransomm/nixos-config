pragma Singleton
import QtQuick

// Ember Deep palette — mirrors ../../theme/tokens.nix. Keep these two in
// sync by hand; the palette is frozen in DESIGN-BRIEF.md so it rarely moves.
QtObject {
    readonly property QtObject color: QtObject {
        readonly property color bg: "#10141f"
        readonly property color bgAlt: "#161c2b"
        readonly property color surface: "#243b40"
        readonly property color muted: "#3f4f7a"
        readonly property color fgDim: "#9aa3b8"
        readonly property color fg: "#e5e9f2"
        readonly property color fgBright: "#f0ece2"

        readonly property color accent: "#c14a1f"
        readonly property color accentDeep: "#8b2408"
        readonly property color accentPressed: "#5a1705"

        readonly property color teal: "#4e8790"
        readonly property color green: "#2f7a4f"
        readonly property color maroon: "#7a2531"
        readonly property color sand: "#e6c384"
    }

    readonly property QtObject radius: QtObject {
        readonly property int sm: 6
        readonly property int md: 10
        readonly property int lg: 14
        readonly property int pill: 20
    }

    readonly property QtObject gap: QtObject {
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 10
        readonly property int lg: 16
    }

    readonly property QtObject font: QtObject {
        readonly property string mono: "JetBrainsMono Nerd Font"
        readonly property string sans: "Inter"
        readonly property string icon: "Symbols Nerd Font"
        readonly property int sizeBar: 13
        readonly property int sizeUi: 12
    }

    // "Settle, don't snap" — reused across every panel's show/hide animation.
    // Easing.BezierSpline control points (CSS cubic-bezier(0.16,1,0.3,1) with
    // the implicit (1,1) endpoint appended).
    readonly property int animDuration: 180
    readonly property var easeOut: [0.16, 1, 0.3, 1, 1, 1]
}
