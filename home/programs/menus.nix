{ config, pkgs, ... }:

let
  t = import ../../theme/tokens.nix;

  # A shared rofi theme string for these menus (compact centered list).
  menuTheme = pkgs.writeText "rofi-menu.rasi" ''
    * {
      bg: ${t.color.bg};
      bg-alt: ${t.color.bgAlt};
      surface: ${t.color.surface};
      fg: ${t.color.fg};
      accent: ${t.color.accent};
      background-color: transparent;
      text-color: @fg;
    }
    window { background-color: @bg; border: 2px; border-color: @surface;
             border-radius: ${toString t.radius.lg}px; width: 340px; padding: 8px; }
    listview { lines: 5; spacing: 4px; }
    element { padding: 10px 14px; border-radius: ${toString t.radius.md}px; }
    element selected { background-color: @accent; text-color: ${t.color.fgBright}; }
    element-text { vertical-align: 0.5; }
  '';

  # Power menu — icon-led entries, confirm on the destructive ones.
  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    chosen=$(printf " Lock\n Suspend\n Reboot\n Shutdown\n Logout" \
      | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -p "power" -theme ${menuTheme})
    case "$chosen" in
      *Lock)     hyprlock ;;
      *Suspend)  systemctl suspend ;;
      *Reboot)   systemctl reboot ;;
      *Shutdown) systemctl poweroff ;;
      *Logout)   hyprctl dispatch exit ;;
    esac
  '';

  # Screenshot menu — region, window, full, and delayed.
  screenshotMenu = pkgs.writeShellScriptBin "screenshot-menu" ''
    dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
    f="$dir/shot-$(date +%Y%m%d-%H%M%S).png"
    chosen=$(printf " Region\n Window\n Full screen\n Delayed 5s" \
      | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -p "screenshot" -theme ${menuTheme})
    case "$chosen" in
      *Region) ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$f" ;;
      *Window) ${pkgs.grim}/bin/grim -g "$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$f" ;;
      *Full*)  ${pkgs.grim}/bin/grim "$f" ;;
      *Delayed*) sleep 5; ${pkgs.grim}/bin/grim "$f" ;;
      *) exit 0 ;;
    esac
    [ -f "$f" ] && ${pkgs.wl-clipboard}/bin/wl-copy < "$f" && \
      ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$(basename "$f")"
  '';

  # Wifi picker — lists networks, connects via nmcli.
  wifiMenu = pkgs.writeShellScriptBin "wifi-menu" ''
    ${pkgs.networkmanager}/bin/nmcli -t -f SSID,SIGNAL dev wifi list \
      | awk -F: '$1!="" {printf "%s  (%s%%)\n", $1, $2}' | sort -u \
      | ${pkgs.rofi-wayland}/bin/rofi -dmenu -i -p "wifi" -theme ${menuTheme} \
      | awk '{print $1}' | xargs -r -I{} sh -c '
          ${pkgs.networkmanager}/bin/nmcli dev wifi connect "{}" || \
          ${pkgs.networkmanager}/bin/nmcli --ask dev wifi connect "{}"'
  '';
in
{
  home.packages = [ powerMenu screenshotMenu wifiMenu pkgs.jq pkgs.libnotify ];
}
