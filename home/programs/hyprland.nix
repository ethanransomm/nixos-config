{ config, pkgs, inputs, ... }:

let
  t = import ../../theme/tokens.nix;
  # strip leading '#' for hyprland's rgb()/rgba() color format
  hx = c: builtins.substring 1 (builtins.stringLength c) c;
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    # Use the same flake Hyprland package as the system module.
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    # Load hyprexpo — the window overview grid (end-4 style zoom-out).
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];

    settings = {
      monitor = [ ",preferred,auto,1" ];   # set real output via `hyprctl monitors`

      exec-once = [
        "waybar"
        "swww-daemon"                       # animated wallpaper daemon
        "swaync"                            # notification center
        "eww open clock-widget"             # desktop clock pill (expands on click)
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, E, exec, nautilus"
        "$mod, R, exec, rofi -show drun"
        "$mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod, L, exec, hyprlock"
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod SHIFT, N, exec, swaync-client -t"   # toggle notification panel
        "$mod, Tab, hyprexpo:expo, toggle"        # window overview grid
        "$mod, D, exec, eww open --toggle clock-widget"  # toggle clock pill (expands on click)
        "$mod, Escape, exec, power-menu"          # power menu
        "$mod SHIFT, S, exec, screenshot-menu"    # screenshot menu
        "$mod, W, exec, wifi-menu"                # wifi picker

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"

        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # ---- Mixed edges: subtle rounding, 2px accent border ----
      general = {
        gaps_in = t.gap.md;
        gaps_out = t.gap.lg;
        border_size = t.border.width;
        # gradient border: rust -> teal at 45deg, so the focused window uses
        # two palette colours instead of one flat accent.
        "col.active_border" = "rgb(${hx t.color.accent}) rgb(${hx t.color.teal}) 45deg";
        "col.inactive_border" = "rgb(${hx t.color.surface})";
        resize_on_border = true;
      };

      decoration = {
        rounding = t.radius.md;
        # restrained blur — floating windows only
        blur = {
          enabled = t.blur.enabled;
          size = t.blur.size;
          passes = t.blur.passes;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 12;
          render_power = 2;
          color = "rgba(${hx t.color.bg}ee)";
        };
        active_opacity = 1.0;
        inactive_opacity = 0.96;
      };

      # ---- Fluid, eased motion (polished: distinct in/out, layered timing) ----
      animations = {
        enabled = true;
        bezier = [
          "easeOut, ${t.anim.easeOut}"
          "standard, ${t.anim.standard}"
          "overshoot, ${t.anim.overshoot}"
          "snappy, 0.2, 0.9, 0.1, 1.02"      # quick with a tiny settle
          "smoothFade, 0.4, 0, 0.2, 1"        # gentle opacity
        ];
        animation = [
          # windows: scale+fade in with a slight overshoot, quicker clean exit
          "windowsIn, 1, ${toString t.anim.speedMed}, overshoot, popin 4%"
          "windowsOut, 1, ${toString t.anim.speedFast}, smoothFade, popin 70%"
          "windowsMove, 1, ${toString t.anim.speedMed}, snappy"
          # borders ripple through the gradient a touch slower for elegance
          "border, 1, ${toString t.anim.speedSlow}, standard"
          # Animated gradient border (rust↔teal slowly rotating). Satisfying,
          # but uses GPU and can flicker on some NVIDIA setups — remove this
          # line if you see flicker:
          "borderangle, 1, 30, standard, loop"
          "fade, 1, ${toString t.anim.speedFast}, smoothFade"
          "fadeDim, 1, ${toString t.anim.speedMed}, smoothFade"
          # workspaces slide with eased momentum
          "workspaces, 1, ${toString t.anim.speedMed}, easeOut, slide"
          "specialWorkspace, 1, ${toString t.anim.speedMed}, overshoot, slidevert"
        ];
      };

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      # ---- hyprexpo: the window overview grid (SUPER+Tab) ----
      plugin.hyprexpo = {
        columns = 3;
        gap_size = 10;
        bg_col = "rgb(${hx t.color.bg})";      # matches desktop base
        workspace_method = "center current";    # grid centres on current ws
        enable_gesture = true;                   # touchpad: 3-finger swipe up
        gesture_fingers = 3;
        gesture_distance = 300;
        gesture_positive = false;
      };
    };
  };
}
