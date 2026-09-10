pragma Singleton
import QtQuick

// Which drop-panel (if any) is currently open. Accordion behaviour — opening
// one closes any other, matching a single bar where every pill's panel
// anchors to the same screen.
QtObject {
    property string openPanel: ""

    // Screen-space centre X of each pill's trigger icon, reported by the bar
    // (see components/BarIconValue.qml) so a panel can drop exactly under
    // whatever it was opened from instead of a guessed static margin.
    property var pillX: ({})

    function toggle(name) {
        openPanel = (openPanel === name) ? "" : name;
    }

    function close() {
        openPanel = "";
    }

    function reportPillX(name, x) {
        const copy = Object.assign({}, pillX);
        copy[name] = x;
        pillX = copy;
    }
}
