{ config, pkgs, ... }:

let
  t = import ../../theme/tokens.nix;
  # Weather: wttr.in one-line, output as waybar JSON. Change the location.
  weatherScript = pkgs.writeShellScript "waybar-weather" ''
    loc="Bath"
    data=$(${pkgs.curl}/bin/curl -sf "https://wttr.in/$loc?format=%c+%t" 2>/dev/null) || data=""
    if [ -z "$data" ]; then
      echo '{"text":"  --","tooltip":"weather unavailable"}'
    else
      # strip leading spaces the emoji sometimes adds
      text=$(echo "$data" | sed 's/^ *//')
      printf '{"text":"%s","tooltip":"%s in '"$loc"'"}\n' "$text" "$text"
    fi
  '';
in
{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 36;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;
      spacing = 8;

      modules-left = [ "custom/logo" "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" "custom/weather" ];
      modules-right = [ "group/time" "group/system" "group/power" ];

      # Three grouped capsules, matching the reference: a media/time group,
      # a system group (volume/wifi), and a resources group (cpu/temp/battery).
      "group/time" = {
        orientation = "horizontal";
        modules = [ "mpris" "idle_inhibitor" ];
      };
      "group/system" = {
        orientation = "horizontal";
        modules = [ "pulseaudio" "bluetooth" "network" ];
      };
      "group/power" = {
        orientation = "horizontal";
        modules = [ "cpu" "temperature" "battery" "custom/notif" "custom/power" ];
      };

      "custom/logo" = {
        format = "";                       # nixos snowflake
        tooltip = false;
        on-click = "rofi -show drun";
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          "1" = "";  "2" = "";  "3" = "";  "4" = "󰝚";  "5" = "";
          active = "";
          default = "";
        };
      };

      "hyprland/window" = { format = "  {}"; max-length = 32; separate-outputs = true; };

      clock = {
        format = "  {:%a %d %b   %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      "custom/weather" = {
        # simple wttr.in fetch; icon + temp. Script defined in this module.
        exec = "${weatherScript}";
        return-type = "json";
        interval = 900;                       # every 15 min
        format = "{}";
        tooltip = true;
      };

      mpris = {
        format = "{player_icon} {title}";
        format-paused = "  {title}";
        max-length = 26;
        player-icons = { default = ""; spotify = ""; firefox = ""; mpv = ""; };
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = { activated = ""; deactivated = ""; };  # caffeine on/off
        tooltip-format-activated = "caffeine on — screen stays awake";
        tooltip-format-deactivated = "caffeine off";
      };

      temperature = {
        format = " {temperatureC}°C";
        critical-threshold = 82;
        format-critical = " {temperatureC}°C";
        interval = 5;
      };

      cpu = { format = "  {usage}%"; interval = 3; };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "  muted";
        format-icons = {
          headphone = "";
          headset = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      bluetooth = {
        format = "";
        format-connected = "  {num_connections}";
        format-disabled = "󰂲";
        on-click = "blueman-manager";
        tooltip-format = "{controller_alias}\n{num_connections} connected";
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "  wired";
        format-disconnected = "  off";
        on-click = "kitty -e nmtui";
        tooltip-format-wifi = "{essid} ({signalStrength}%)";
      };

      battery = {
        format = "{icon} {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = "  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        states = { warning = 30; critical = 15; };
      };

      "custom/notif" = {
        format = "";
        on-click = "swaync-client -t";
        tooltip = false;
      };

      tray = { spacing = 10; };

      "custom/power" = {
        format = "";
        on-click = "wlogout";
        tooltip = false;
      };
    };

    style = ''
      * {
        font-family: "${t.font.mono}";
        font-size: ${toString t.font.sizeBar}px;
        min-height: 0;
      }
      window#waybar { background: transparent; }

      /* Image-4 style: each cluster is its own rounded pill island. The right
         side reads as separate capsules rather than one long bar. */
      .modules-left, .modules-center, .modules-right {
        background: transparent;
      }

      /* left: logo + segmented workspace pill together */
      #custom-logo {
        background: ${t.color.bgAlt};
        border: 1px solid ${t.color.surface};
        border-radius: ${toString t.radius.lg}px;
        color: ${t.color.accent};
        font-size: 16px;
        padding: 4px 14px;
        margin-right: 8px;
      }
      #workspaces {
        background: ${t.color.bgAlt};
        border: 1px solid ${t.color.surface};
        border-radius: ${toString t.radius.pill}px;
        padding: 2px 4px;
      }

      #workspaces button {
        color: ${t.color.fgDim};
        padding: 0 7px;
        border-radius: ${toString t.radius.pill}px;
        transition: all 0.25s cubic-bezier(0.16,1,0.3,1);
      }
      #workspaces button.active {
        color: ${t.color.fgBright};
        background: ${t.color.accentDeep};
        box-shadow: inset 0 -2px 0 ${t.color.accent};
      }
      #workspaces button:hover { color: ${t.color.teal}; background: ${t.color.surface}; }
      #workspaces button.urgent { color: ${t.color.fgBright}; background: ${t.color.maroon}; }

      #window { color: ${t.color.fgDim}; padding: 0 10px; }

      /* centre: clock + weather as one pill */
      #clock, #custom-weather {
        background: ${t.color.bgAlt};
        border: 1px solid ${t.color.surface};
      }
      #clock {
        color: ${t.color.fgBright}; font-weight: 500;
        border-radius: ${toString t.radius.pill}px 0 0 ${toString t.radius.pill}px;
        padding: 4px 10px 4px 16px; border-right: none;
      }
      #custom-weather {
        color: ${t.color.sand};
        border-radius: 0 ${toString t.radius.pill}px ${toString t.radius.pill}px 0;
        padding: 4px 16px 4px 8px; border-left: none;
      }

      /* RIGHT SIDE: three clean grouped capsules (reference style).
         The pill background lives on the GROUP; modules inside are transparent
         and just add their icon+text with internal padding. */
      #time, #system, #power {
        background: ${t.color.bgAlt};
        border: 1px solid ${t.color.surface};
        border-radius: ${toString t.radius.pill}px;
        padding: 2px 6px;
        margin-left: 8px;
      }

      /* modules inside groups: transparent, even internal spacing */
      #mpris, #idle_inhibitor,
      #pulseaudio, #bluetooth, #network,
      #cpu, #temperature, #battery,
      #custom-notif, #custom-power {
        background: transparent;
        border: none;
        padding: 4px 10px;
      }

      /* per-module accent colours */
      #mpris { color: ${t.color.teal}; }
      #idle_inhibitor { color: ${t.color.fgDim}; }
      #idle_inhibitor.activated { color: ${t.color.sand}; }
      #pulseaudio { color: ${t.color.fg}; }
      #pulseaudio.muted { color: ${t.color.muted}; }
      #bluetooth { color: ${t.color.teal}; }
      #bluetooth.disabled { color: ${t.color.muted}; }
      #network { color: ${t.color.fg}; }
      #network.disconnected { color: ${t.color.accent}; }
      #cpu { color: ${t.color.sand}; }
      #temperature { color: ${t.color.fg}; }
      #temperature.critical { color: ${t.color.accent}; }
      #battery { color: ${t.color.fg}; }
      #battery.charging { color: ${t.color.green}; }
      #battery.warning  { color: ${t.color.sand}; }
      #battery.critical { color: ${t.color.accent}; }
      #custom-notif { color: ${t.color.teal}; font-size: 15px; }
      #custom-notif:hover { color: ${t.color.accent}; }
      #custom-power { color: ${t.color.accent}; font-size: 15px; }
      #custom-power:hover { color: ${t.color.fgBright}; }
    '';
  };
}
