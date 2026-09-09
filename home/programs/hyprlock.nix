{ config, pkgs, ... }:

let
  t = import ../../theme/tokens.nix;
  rgb = c: "rgb(" + (builtins.substring 1 6 c) + ")";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        monitor = "";
        path = "screenshot";        # blurs your current screen — clean + fast
        blur_passes = 3;
        blur_size = 8;
        color = rgb t.color.bg;
      };

      # Big soft clock
      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = "${t.font.sans}";
          color = rgb t.color.fgBright;
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date +'%A, %d %B'";
          font_size = 20;
          font_family = "${t.font.sans}";
          color = rgb t.color.fgDim;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          # user greeting in teal
          monitor = "";
          text = "  $USER";
          font_size = 16;
          font_family = "${t.font.mono}";
          color = rgb t.color.teal;
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
        {
          # battery line in sand, bottom corner
          monitor = "";
          text = "cmd[update:30000] echo \"  $(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)%\"";
          font_size = 14;
          font_family = "${t.font.mono}";
          color = rgb t.color.sand;
          position = "-30, 30";
          halign = "right";
          valign = "bottom";
        }
      ];

      # Clean auth field with rust accent when typing
      input-field = [{
        monitor = "";
        size = "300, 54";
        outline_thickness = 2;
        rounding = t.radius.md;
        dots_size = 0.25;
        dots_spacing = 0.3;
        outer_color = rgb t.color.accent;
        inner_color = rgb t.color.bgAlt;
        font_color = rgb t.color.fg;
        check_color = rgb t.color.green;
        fail_color = rgb t.color.accentDeep;
        placeholder_text = "enter password";
        position = "0, -40";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
