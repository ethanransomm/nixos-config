{ config, pkgs, ... }:

let t = import ../../theme/tokens.nix;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.kitty}/bin/kitty";

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      sorting-method = "fzf";        # fuzzy matching
      matching = "fuzzy";
    };

    # Themed as a floating rounded card matching the desktop.
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg      = mkLiteral t.color.bg;
        bg-alt  = mkLiteral t.color.bgAlt;
        surface = mkLiteral t.color.surface;
        fg      = mkLiteral t.color.fg;
        fg-dim  = mkLiteral t.color.fgDim;
        accent  = mkLiteral t.color.accent;

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      "window" = {
        background-color = mkLiteral "@bg";
        border = mkLiteral "2px";
        border-color = mkLiteral "@surface";
        border-radius = mkLiteral "${toString t.radius.lg}px";
        width = mkLiteral "560px";
        padding = mkLiteral "8px";
      };

      "inputbar" = {
        background-color = mkLiteral "@bg-alt";
        border-radius = mkLiteral "${toString t.radius.md}px";
        padding = mkLiteral "10px 14px";
        margin = mkLiteral "0 0 8px 0";
        children = map mkLiteral [ "prompt" "entry" ];
      };
      "prompt" = {
        text-color = mkLiteral t.color.teal;
        margin = mkLiteral "0 10px 0 0";
      };
      "entry"  = {
        placeholder = "  search apps";
        placeholder-color = mkLiteral "@fg-dim";
      };

      "listview" = { lines = 8; scrollbar = false; spacing = mkLiteral "2px"; };
      "element" = {
        padding = mkLiteral "8px 12px";
        border-radius = mkLiteral "${toString t.radius.md}px";
      };
      "element selected" = {
        background-color = mkLiteral "@accent";
        text-color = mkLiteral t.color.fgBright;
      };
      "element-icon" = { size = mkLiteral "20px"; margin = mkLiteral "0 10px 0 0"; };
    };
  };
}
