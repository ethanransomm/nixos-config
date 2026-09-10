{ config, pkgs, lib, ... }:

{
  # Stylix themes Kitty's colors/font automatically. Just your behavioural
  # preferences go here.
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = lib.mkForce "0.95";
      confirm_os_window_close = 0;
      scrollback_lines = 10000;
      enable_audio_bell = false;
    };
    # keybindings, etc. can go here too — see `man kitty.conf` mapped to Nix.
  };
}
