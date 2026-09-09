{ config, pkgs, ... }:

{
  # swww = animated wallpaper daemon with GPU transitions. The daemon is
  # started in hyprland.nix (exec-once). Set your wallpaper with an eased fade:
  #
  #   swww img ~/wallpapers/wallpaper.jpg \
  #     --transition-type grow --transition-pos center \
  #     --transition-fps 60 --transition-duration 1.2
  #
  # For a rotating/animated set, a simple timer script is included below.

  home.packages = with pkgs; [
    swww
    cliphist          # clipboard history (bound to SUPER+V)
    wl-clipboard
    pavucontrol       # audio control (opened from waybar)
    nautilus          # file manager (SUPER+E)
    playerctl         # media keys / mpris
  ];

  # Optional: rotate wallpapers every 15 min with a smooth transition.
  # Put images in ~/wallpapers/ and enable this service.
  systemd.user.services.wallpaper-rotate = {
    Unit.Description = "Rotate wallpaper with swww";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "wallpaper-rotate" ''
        WALL=$(find "$HOME/wallpapers" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n1)
        ${pkgs.swww}/bin/swww img "$WALL" \
          --transition-type wipe --transition-angle 30 \
          --transition-fps 60 --transition-duration 1.5
      '';
    };
  };
  systemd.user.timers.wallpaper-rotate = {
    Unit.Description = "Rotate wallpaper timer";
    Timer = { OnUnitActiveSec = "15min"; OnBootSec = "1min"; };
    Install.WantedBy = [ "timers.target" ];
  };
}
