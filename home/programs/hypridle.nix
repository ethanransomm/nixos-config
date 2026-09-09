{ config, pkgs, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        # dim the backlight as a gentle warning
        { timeout = 150; on-timeout = "brightnessctl -s set 10%";
          on-resume = "brightnessctl -r"; }
        # lock
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        # screen off
        { timeout = 360; on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on"; }
        # suspend (laptop)
        { timeout = 1800; on-timeout = "systemctl suspend"; }
      ];
    };
  };
}
