{ config, pkgs, ... }:

let t = import ../../theme/tokens.nix;
in
{
  # Power menu opened from the Waybar power icon (and SUPER+Escape if you bind it).
  programs.wlogout = {
    enable = true;
    layout = [
      { label = "lock";      action = "hyprlock";           text = "Lock";      keybind = "l"; }
      { label = "logout";    action = "hyprctl dispatch exit"; text = "Logout"; keybind = "e"; }
      { label = "suspend";   action = "systemctl suspend";  text = "Suspend";   keybind = "s"; }
      { label = "reboot";    action = "systemctl reboot";   text = "Reboot";    keybind = "r"; }
      { label = "shutdown";  action = "systemctl poweroff"; text = "Shutdown";  keybind = "p"; }
    ];

    style = ''
      * {
        font-family: "${t.font.mono}";
        font-size: 14px;
        color: ${t.color.fg};
      }
      window { background: rgba(16,20,31,0.85); }

      button {
        background: ${t.color.bgAlt};
        border: 2px solid ${t.color.surface};
        border-radius: ${toString t.radius.lg}px;
        margin: 10px;
        color: ${t.color.fgDim};
        transition: all 0.2s cubic-bezier(0.16,1,0.3,1);
        background-repeat: no-repeat;
        background-position: center;
        background-size: 28%;
      }
      button:hover {
        background-color: ${t.color.surface};
        color: ${t.color.fgBright};
        border-color: ${t.color.accent};
      }
      button:focus {
        background-color: ${t.color.accentDeep};
        border-color: ${t.color.accent};
        color: ${t.color.fgBright};
      }
    '';
  };

  # Bluetooth applet in the tray (pairs with the waybar bluetooth module).
  services.blueman-applet.enable = true;
}
