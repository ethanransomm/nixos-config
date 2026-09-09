{ config, pkgs, inputs, ... }:

{
  # Use Hyprland from the flake input so hyprexpo (built against the same
  # version) loads without an ABI mismatch.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
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
    wayland.enable = true;
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
  ];
}
