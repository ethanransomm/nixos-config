import Quickshell
import Quickshell.Io
import "modules"
import "panels"

ShellRoot {
    Bar {}

    // Panels — each is a top-level DropPanel that opens when
    // PanelState.openPanel matches its name.
    Wifi {}
    Bluetooth {}
    Volume {}
    Notifications {}
    Battery {}
    Media {}
    Laptop {}
    Clock {}
    Clipboard {}
    Overview {}

    // Lets Hyprland keybinds reach into the shell:
    // `quickshell ipc call panels toggle <name>`
    IpcHandler {
        target: "panels"
        function toggle(name: string): void { PanelState.toggle(name); }
        function open(name: string): void { PanelState.openPanel = name; }
        function close(): void { PanelState.close(); }
    }
}
