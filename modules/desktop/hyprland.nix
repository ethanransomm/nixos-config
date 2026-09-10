{ config, pkgs, inputs, ... }:

let
  # Bespoke SDDM greeter matching the hyprlock lock screen — same background
  # art, same clock/accent language — so login and lock read as one theme
  # instead of two unrelated pieces of software. Source lives in
  # theme/sddm-theme/; only theme.conf needs a Nix-store path baked in.
  emberDeepSddmTheme = pkgs.runCommand "sddm-theme-ember-deep" { } ''
    themeDir="$out/share/sddm/themes/ember-deep"
    mkdir -p "$themeDir"
    cp ${../../theme/sddm-theme/Main.qml} "$themeDir/Main.qml"
    cp ${../../theme/sddm-theme/metadata.desktop} "$themeDir/metadata.desktop"
    {
      echo "[General]"
      echo "background=${../../theme/lockscreen.jpg}"
    } > "$themeDir/theme.conf"
  '';
in
{
  # Use Hyprland from the flake input so hyprexpo (built against the same
  # version) loads without an ABI mismatch.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Hyprland's binary cache — without this, pulling Hyprland from the flake
  # recompiles it (and all deps) from source on every update. This makes it
  # download prebuilt instead.
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # Login manager — SDDM in Wayland mode pairs well with Hyprland rices.
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      # weston (the default) has no way to set a cursor theme at all in this
      # module — its weston.ini is generated internally with only
      # [libinput]/[keyboard] sections (see
      # nixos/modules/services/display-managers/sddm.nix), no [shell]
      # cursor-theme key, and it's not exposed through `settings`. kwin_wayland
      # DOES actively look one up (confirmed via `journalctl`:
      # "kwin_core: Unable to load any cursor theme" — it was searching, just
      # finding nothing because XCURSOR_THEME wasn't set yet). That's what
      # GreeterEnvironment below now provides.
      compositor = "kwin";
    };
    theme = "ember-deep";
    # The greeter runs as its own system user, outside home-manager/Stylix —
    # without this it has no cursor theme at all, which is what made the
    # trackpad look "invisible". `settings.Theme.CursorTheme/CursorSize`
    # alone only exposes the value to theme QML via a context property — it
    # does NOT set XCURSOR_THEME, which is what kwin/Qt actually read to
    # render the pointer, hence GreeterEnvironment too. Bibata matches the
    # cursor Stylix already sets for the real session
    # (modules/desktop/stylix.nix).
    settings = {
      Theme = {
        CursorTheme = "Bibata-Modern-Ice";
        CursorSize = "24";
      };
      # NixOS's own kwin wiring sets GreeterEnvironment too (for
      # QT_WAYLAND_SHELL_INTEGRATION=layer-shell, required for kwin) — our
      # `settings` overrides that default entirely (recursiveUpdate replaces
      # the whole string, it doesn't merge/append), so it has to be repeated
      # here alongside the cursor vars or kwin loses its layer-shell mode.
      General.GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell,XCURSOR_THEME=Bibata-Modern-Ice,XCURSOR_SIZE=24";
    };
  };

  # Screen sharing / file pickers under Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # hyprlock needs a PAM entry to authenticate, or it accepts your password
  # but never unlocks. This is the classic "lockscreen won't unlock" fix.
  security.pam.services.hyprlock = {};

  # NVIDIA + Wayland environment hints.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";       # Electron/Chromium apps use Wayland
    # If you hit flicker/cursor issues on NVIDIA, this sometimes helps:
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # System-level Wayland utilities the rice depends on.
  environment.systemPackages = with pkgs; [
    wl-clipboard
    hyprpaper hyprlock hypridle
    grim slurp          # screenshots
    brightnessctl       # laptop backlight
    quickshell
    emberDeepSddmTheme
    bibata-cursors      # so the SDDM greeter (outside home-manager) can find it too
  ];
}
