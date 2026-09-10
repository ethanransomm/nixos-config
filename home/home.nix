{ config, pkgs, inputs, ... }:

{
  imports = [
    ./programs/hyprland-wm.nix
    ./programs/kitty.nix
    ./programs/shell.nix
    ./programs/dev.nix
    ./programs/hyprlock.nix
    ./programs/hypridle.nix
    ./programs/rofi.nix
    ./programs/notifications.nix
    ./programs/wallpaper.nix
    ./programs/powermenu.nix
    ./programs/quickshell.nix
  ];

  stylix.targets = {
    rofi.enable = true;
    kitty.enable = true;
    hyprlock.enable = true;
    hyprland.enable = true;
  };

  home.username = "ethan";
  home.homeDirectory = "/home/ethan";

  home.packages = with pkgs; [
    fastfetch
    firefox
    file-roller
    grim slurp
    brightnessctl
    curl                # weather module
    libnotify           # notify-send — screenshot confirmation, etc.
    blueman             # full bluetooth manager — pairing wizard the bar panel doesn't cover
    playerctl           # mpris media control
    kdePackages.dolphin
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
