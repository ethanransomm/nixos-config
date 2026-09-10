{ config, pkgs, inputs, ... }:

{
  imports = [
    ./programs/hyprland-wm.nix
    ./programs/waybar.nix
    ./programs/kitty.nix
    ./programs/shell.nix
    ./programs/dev.nix
    ./programs/hyprlock.nix
    ./programs/hypridle.nix
    ./programs/rofi.nix
    ./programs/notifications.nix
    ./programs/wallpaper.nix
    ./programs/powermenu.nix
 #   ./programs/widgets.nix
 #   ./programs/menus.nix
  ];


  home.username = "ethan";
  home.homeDirectory = "/home/ethan";

  home.packages = with pkgs; [
    fastfetch
    firefox
    file-roller
    grim slurp
    brightnessctl
    curl                # weather module
    blueman             # bluetooth manager (waybar click)
    playerctl           # mpris media control
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
