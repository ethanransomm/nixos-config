{ config, pkgs, ... }:

let
  # The real source of truth is the tracked QML tree at ../quickshell — this
  # symlinks it in place (rather than copying into the Nix store) so editing
  # any .qml file takes effect on the next Quickshell restart, no rebuild
  # needed. Still fully reproducible: the tree lives in the flake, not in
  # ~/.config by accident.
  quickshellSrc = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nixos-config/home/quickshell";
in
{
  home.file.".local/bin/quickshell-bar" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec quickshell -p "$HOME/.config/quickshell/shell.qml"
    '';
  };

  xdg.configFile."quickshell".source = quickshellSrc;
}
