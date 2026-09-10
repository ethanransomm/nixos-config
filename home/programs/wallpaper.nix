{ config, pkgs, ... }:

{
  # Wallpaper is hyprpaper, pointed at the same file Stylix derives its
  # colour scheme from (theme/../home/wallpapers/wallpaper.jpg — see
  # modules/desktop/stylix.nix) so there's exactly one file to replace.
  #
  # To change it: drop your image at home/wallpapers/wallpaper.jpg (same
  # filename) and run `rebuild`. To preview something instantly without a
  # rebuild:
  #   hyprctl hyprpaper preload /path/to/image.png
  #   hyprctl hyprpaper wallpaper ",/path/to/image.png"
  services.hyprpaper = {
    enable = true;
    # Started via hl.on("hyprland.start", ...) in hyprland.lua instead, like
    # everything else this shell autostarts — our systemd session target
    # isn't reliably up in time with the custom Lua Hyprland config, so skip
    # generating the systemd unit and just keep the declarative config file.
    package = null;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${../../home/wallpapers/wallpaper.jpg}" ];
      wallpaper = [ ",${../../home/wallpapers/wallpaper.jpg}" ];
    };
  };

  home.packages = with pkgs; [
    cliphist          # clipboard history (bound to SUPER+V)
    wl-clipboard
    pavucontrol       # audio control
    nautilus          # file manager (SUPER+E)
    playerctl         # media keys / mpris
  ];
}
