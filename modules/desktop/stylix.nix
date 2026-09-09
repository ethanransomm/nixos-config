{ config, pkgs, ... }:

{
  # Stylix themes the whole system from ONE scheme. We point it at our custom
  # "Ember Deep" base16 file (built from your palette) so Kitty, GTK, SDDM,
  # cursors, and app colors all stay consistent. Waybar/Hyprland/rofi we style
  # by hand (below / in home/) for full control, so we disable Stylix there.
  stylix = {
    enable = true;

    base16Scheme = ../../theme/ember-deep.yaml;
    polarity = "dark";

    # A wallpaper that matches the scheme (drop your file here). Stylix uses it
    # for the desktop + lockscreen base. swww handles the animated layer.
    image = ../../home/wallpapers/wallpaper.jpg;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = { package = pkgs.inter; name = "Inter"; };
      sizes = { applications = 11; terminal = 12; desktop = 11; };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
