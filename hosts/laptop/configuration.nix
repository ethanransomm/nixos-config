{ config, pkgs, inputs, ... }:

{
  imports = [
    # Generated on the real machine by `nixos-generate-config`.
    # Do NOT hand-write this — replace the placeholder with your real one.
    ./hardware-configuration.nix

    ../../modules/system/boot.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/networking.nix
    ../../modules/system/gaming.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/stylix.nix
  ];

  # ---- Identity ----
  networking.hostName = "laptop";
  users.users.ethan = {
    isNormalUser = true;
    description = "Your Name";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # ---- Locale / time ----
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  # ---- Nix settings ----
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;   # NVIDIA, Steam, etc. need this.

  # ---- System-wide packages (keep lean; user stuff goes in home/) ----
  environment.systemPackages = with pkgs; [
    git wget curl
    vim
  ];

  # ---- Fonts ----
  # Install Nerd Fonts explicitly (not just via Stylix) so Waybar and every
  # app can always find the icon glyphs. This fixes missing/blank icons.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only   # icon glyphs as a fallback for any font
    inter
    noto-fonts
    noto-fonts-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "Inter" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # First install target. Once set, don't casually bump it.
  system.stateVersion = "25.11";
}
