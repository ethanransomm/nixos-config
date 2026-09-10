{ config, pkgs, ... }:

{
  # Dev tooling. For per-project toolchains, prefer `nix develop` / devshells
  # over installing everything globally — but these are your always-on tools.
  home.packages = with pkgs; [
    # languages / runtimes
    nodejs
    python3
    gcc
    rustup

    # editors
    neovim
    vscode

    # containers & infra
    docker-compose
    lazygit
    gh              # GitHub CLI

    # misc CLI
    ripgrep fd bat eza jq
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Your Name";        # CHANGE
      email = "you@example.com"; # CHANGE
    };
  };

  # Docker daemon is enabled system-side; add this to configuration.nix:
  #   virtualisation.docker.enable = true;
  #   users.users.ethan.extraGroups = [ "docker" ];
}
