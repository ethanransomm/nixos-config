{ config, pkgs, lib, ... }:

let t = import ../../theme/tokens.nix;
in
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "eza -lah --icons --git";
      ls = "eza --icons";
      cat = "bat";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#laptop";
      update = "nix flake update --flake ~/nixos-config";
    };

    interactiveShellInit = ''
      set fish_greeting
      # source your personal fish config (functions, abbrs, env) if present
      if test -f ~/.config/fish/personal.fish
        source ~/.config/fish/personal.fish
      end
      fastfetch
    '';
  };

  # Your personal fish config, kept verbatim. Replace the placeholder file with
  # your backed-up config.fish. Symlinked to a separate name so it doesn't
  # clash with Home Manager's generated ~/.config/fish/config.fish.
  xdg.configFile."fish/personal.fish".source = ../dotfiles/fish/config.fish;

  # Your fastfetch config, kept verbatim.
  xdg.configFile."fastfetch/config.jsonc".source = ../dotfiles/fastfetch/config.jsonc;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](#c14a1f)";
        error_symbol = "[❯](#8b2408)";
      };
      directory.style = "#4e8790";
      git_branch.style = "#e6c384";
      git_status.style = "#c14a1f";
    };
  };

  programs.eza.enable = true;
  programs.bat = {
    enable = true;
    config.theme = lib.mkForce "base16";
  };
}
