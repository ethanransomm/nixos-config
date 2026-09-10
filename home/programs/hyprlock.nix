{ config, pkgs, lib, ... }:

let
  t = import ../../theme/tokens.nix;
  rgb = c: "rgb(" + (builtins.substring 1 6 c) + ")";
  rgba = c: alphaHex: "rgba(" + (builtins.substring 1 6 c) + alphaHex + ")";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = false;
      };

      background = {
        monitor = "";
        # A designed dark gradient with ember/teal ambient orbs, not a blur of
        # whatever windows happen to be open — see theme/lockscreen.jpg.
        path = lib.mkForce "${../../theme/lockscreen.jpg}";
        blur_passes = 1;
        blur_size = 4;
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
          # user greeting in teal. font_family is a fallback chain,
          # icon font first: JetBrainsMono Nerd Font's PUA glyph at this
          # codepoint is a different, wrong design (see the power-row
          # comment below) — Pango tries Symbols Nerd Font first for the
          # icon character, falls back to mono for plain "$USER" text
          # (Symbols Nerd Font has no Latin coverage of its own).
          monitor = "";
          text = "  $USER";
          font_size = 16;
          font_family = "${t.font.icon},${t.font.mono}";
          color = rgb t.color.teal;
          position = "0, -130";
          halign = "center";
          valign = "center";
        }
        {
          # wifi + battery status, top-right corner. Same icon-first
          # fallback chain as the username label above.
          monitor = "";
          text = "cmd[update:30000] echo \"     $(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)%\"";
          font_size = 16;
          font_family = "${t.font.icon},${t.font.mono}";
          color = rgb t.color.fgDim;
          position = "-30, -30";
          halign = "right";
          valign = "top";
        }
        {
          # time-of-day greeting, a little warmth above the clock
          monitor = "";
          text = ''cmd[update:300000] sh -c 'h=$(date +%H); if [ $h -lt 12 ]; then echo "<i>good morning</i>"; elif [ $h -lt 18 ]; then echo "<i>good afternoon</i>"; else echo "<i>good evening</i>"; fi' '';
          font_size = 15;
          font_family = "${t.font.sans}";
          color = rgb t.color.teal;
          position = "0, 230";
          halign = "center";
          valign = "center";
        }
        {
          # power row, bottom-right — suspend / restart / shutdown, click-to-run.
          # Plain glyphs, same treatment as the wifi/battery label above —
          # no circular backdrop (that was a real but separate problem,
          # fixed earlier). The actual bug behind "restart/power look
          # wrong": JetBrainsMono Nerd Font's own patched glyph at these two
          # codepoints (0xf021, 0xf011) is a different, worse-looking design
          # than what Symbols Nerd Font has at the same codepoints — verified
          # by comparing against Quickshell's Battery panel, which already
          # uses Symbols Nerd Font for these exact icons and renders them
          # correctly. font.icon now points at Symbols Nerd Font.
          monitor = "";
          text = "";
          font_size = 22;
          font_family = "${t.font.icon}";
          color = rgb t.color.teal;
          onclick = "systemctl suspend";
          position = "-100, 30";
          halign = "right";
          valign = "bottom";
        }
        {
          monitor = "";
          text = "";
          font_size = 22;
          font_family = "${t.font.icon}";
          color = rgb t.color.sand;
          onclick = "systemctl reboot";
          position = "-60, 30";
          halign = "right";
          valign = "bottom";
        }
        {
          monitor = "";
          text = "";
          font_size = 22;
          font_family = "${t.font.icon}";
          color = rgb t.color.maroon;
          onclick = "systemctl poweroff";
          position = "-20, 30";
          halign = "right";
          valign = "bottom";
        }
      ];

      # Clean auth field with rust accent when typing
      input-field = lib.mkForce [{
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
