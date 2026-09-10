import QtQuick 2.15

// Ember Deep SDDM greeter — mirrors the hyprlock lock screen (same
// background art, same clock treatment, same rust/teal accent language) so
// the login screen and lock screen read as one continuous design instead of
// two unrelated pieces of software.
Rectangle {
    id: root
    width: 640
    height: 480
    color: bg

    readonly property color bg: "#10141f"
    readonly property color bgAlt: "#161c2b"
    readonly property color surface: "#243b40"
    readonly property color fgDim: "#9aa3b8"
    readonly property color fg: "#e5e9f2"
    readonly property color fgBright: "#f0ece2"
    readonly property color accent: "#c14a1f"
    readonly property color teal: "#4e8790"
    readonly property color maroon: "#7a2531"
    readonly property color sand: "#e6c384"

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontSans: "Inter"
    // Dedicated icon font — JetBrainsMono Nerd Font's own patched glyphs at
    // some codepoints (0xf021 refresh, 0xf011 power confirmed) are a
    // different, worse-looking design than Symbols Nerd Font's at the same
    // codepoints. Every icon-only Text element below should use this, not
    // fontMono (fontMono stays for anything mixing icons with real text).
    readonly property string fontIcon: "Symbols Nerd Font"

    function ch(code) { return String.fromCodePoint(code); }
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }
    readonly property string iconUser: ch(0xf007)
    readonly property string iconWifi: ch(0xf1eb)
    readonly property string iconPower: ch(0xf011)
    readonly property string iconRestart: ch(0xf021)
    readonly property string iconSuspend: ch(0xf186)

    readonly property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    // userModel.lastUser is unset when there's no login history yet (e.g. a
    // fresh account, or SDDM's --test-mode) — this is a single-user machine,
    // so fall back to the one real account rather than show a blank field.
    readonly property string currentUser: userModel.lastUser.length ? userModel.lastUser : "ethan"
    property date now: new Date()

    function tryLogin() {
        sddm.login(root.currentUser, pwInput.text, root.sessionIndex);
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    Connections {
        target: sddm
        function onLoginFailed() {
            errText.color = root.maroon;
            errText.text = "incorrect password";
            pwInput.text = "";
        }
        function onInformationMessage(message) {
            errText.color = root.fgDim;
            errText.text = message;
        }
    }

    // Same background art as hyprlock — see theme/lockscreen.jpg.
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        onStatusChanged: if (status === Image.Error) root.color = root.bg
    }

    // Top-right status glyph, same corner as the lock screen. (Reading live
    // battery/wifi state needs local file access XMLHttpRequest disables by
    // default for greeter QML — not worth loosening for a decorative label.)
    Text {
        anchors { top: parent.top; right: parent.right; topMargin: 30; rightMargin: 30 }
        text: root.iconWifi
        font.family: root.fontIcon
        font.pixelSize: 16
        color: root.fgDim
    }

    // Big soft clock, same font sizes as hyprlock.
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "hh:mm")
            font.family: root.fontSans
            font.pixelSize: 90
            color: root.fgBright
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "dddd, d MMMM")
            font.family: root.fontSans
            font.pixelSize: 20
            color: root.fgDim
        }
    }

    // Soft card grouping the auth cluster — structure instead of bare text
    // floating on the wallpaper, matching hyprlock's card treatment.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: authColumn.y - 24
        width: Math.max(340, authColumn.implicitWidth + 48)
        height: authColumn.implicitHeight + 48
        radius: 16
        color: root.alpha(root.bgAlt, 0.55)
        border.width: 1
        border.color: root.alpha(root.accent, 0.25)
    }

    // Avatar + name + password, centred just below the clock.
    Column {
        id: authColumn
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.56
        spacing: 18

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Rectangle {
                id: avatarRing
                width: 34; height: 34; radius: 17
                color: root.surface
                border.width: 1
                property real glow: 1.0
                border.color: root.alpha(root.accent, glow)
                SequentialAnimation on glow {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.45; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.45; duration: 1800; easing.type: Easing.InOutSine }
                }
                Text {
                    anchors.centerIn: parent
                    text: root.iconUser
                    font.family: root.fontIcon
                    font.pixelSize: 15
                    color: root.fgBright
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentUser
                font.family: root.fontMono
                font.pixelSize: 16
                color: root.teal
            }
        }

        Rectangle {
            id: pwBox
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300; height: 54
            radius: 8
            color: root.bgAlt
            border.width: 2
            border.color: pwInput.activeFocus ? root.accent : root.surface

            Text {
                anchors.centerIn: parent
                text: "enter password"
                color: root.fgDim
                font.family: root.fontMono
                font.pixelSize: 15
                visible: !pwInput.text.length && !pwInput.activeFocus
            }

            TextInput {
                id: pwInput
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "*"
                clip: true
                color: root.fg
                font.family: root.fontMono
                font.pixelSize: 15
                focus: true
                Keys.onReturnPressed: root.tryLogin()
                Keys.onEnterPressed: root.tryLogin()
            }
        }

        Text {
            id: errText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            font.family: root.fontMono
            font.pixelSize: 12
            color: root.maroon
        }
    }

    // Power actions, bottom-right — same glyph set as the Battery & Power panel.
    Row {
        anchors { bottom: parent.bottom; right: parent.right; margins: 24 }
        spacing: 12

        Repeater {
            model: [
                { glyph: root.iconSuspend, tint: root.teal, avail: sddm.canSuspend, act: 0 },
                { glyph: root.iconRestart, tint: root.sand, avail: sddm.canReboot, act: 1 },
                { glyph: root.iconPower, tint: root.maroon, avail: sddm.canPowerOff, act: 2 }
            ]
            delegate: Rectangle {
                visible: modelData.avail
                width: 52; height: 52; radius: 26
                color: root.alpha(root.bgAlt, 0.75)
                border.width: 1
                border.color: modelData.tint

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    font.family: root.fontIcon
                    font.pixelSize: 19
                    color: modelData.tint
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.act === 0) sddm.suspend();
                        else if (modelData.act === 1) sddm.reboot();
                        else sddm.powerOff();
                    }
                }
            }
        }
    }

    Component.onCompleted: pwInput.forceActiveFocus()
}
