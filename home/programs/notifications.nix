{ config, pkgs, ... }:

let t = import ../../theme/tokens.nix;
in
{
  # SwayNC = notifications + a slide-out control center with a DND toggle.
  # Toggle the panel with SUPER+SHIFT+N (bound in hyprland.nix).
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-width = 380;
      control-center-margin-top = 12;
      control-center-margin-right = 12;
      notification-icon-size = 48;
      timeout = 8;
      timeout-low = 4;
      timeout-critical = 0;

      widgets = [ "title" "dnd" "mpris" "notifications" ];
      widget-config = {
        title = { text = "notifications"; clear-all-button = true; };
        dnd = { text = "do not disturb"; };
        mpris = { image-size = 88; image-radius = 8; };
      };
    };

    style = ''
      * { font-family: "${t.font.mono}"; }

      .control-center {
        background: ${t.color.bg};
        border: 2px solid ${t.color.surface};
        border-radius: ${toString t.radius.lg}px;
        color: ${t.color.fg};
      }
      .control-center .widget-title { color: ${t.color.fgBright}; font-weight: 500; }

      /* DND toggle uses the rust accent when on */
      .widget-dnd > switch { background: ${t.color.surface}; border-radius: ${toString t.radius.pill}px; }
      .widget-dnd > switch:checked { background: ${t.color.accent}; }

      .notification {
        background: ${t.color.bgAlt};
        border: 1px solid ${t.color.surface};
        border-radius: ${toString t.radius.md}px;
        margin: 6px;
        padding: 4px;
      }
      .notification.low { border-left: 3px solid ${t.color.teal}; border-radius: 0 ${toString t.radius.md}px ${toString t.radius.md}px 0; }
      .notification.normal { border-left: 3px solid ${t.color.green}; border-radius: 0 ${toString t.radius.md}px ${toString t.radius.md}px 0; }
      .notification.critical { border-left: 3px solid ${t.color.accent}; border-radius: 0 ${toString t.radius.md}px ${toString t.radius.md}px 0; }
      .notification-content { color: ${t.color.fg}; }
      .summary { color: ${t.color.fgBright}; font-weight: 500; }
      .body { color: ${t.color.fgDim}; }

      .close-button {
        background: ${t.color.surface};
        color: ${t.color.fgBright};
        border-radius: ${toString t.radius.sm}px;
      }
      .close-button:hover { background: ${t.color.accent}; }
    '';
  };
}
