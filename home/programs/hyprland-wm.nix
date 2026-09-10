{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
}
