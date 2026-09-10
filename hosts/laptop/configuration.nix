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
    ../../modules/system/nix-ld.nix
#    ../../home/home.nix
  ];

  # ---- Identity ----
  networking.hostName = "laptop";
  users.users.ethan = {
    isNormalUser = true;
    description = "ethan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;
  # ---- Locale / time ----
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb.layout = "gb";
  console.keyMap = "uk";

  # ---- Nix settings ----
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;   # NVIDIA, Steam, etc. need this.

  # ---- Battery panel backend ----
  services.upower.enable = true;

  # ---- Laptop control panel backend ----
  # energy_uj is root-only (0400) by default, which silently breaks any
  # userspace power monitor (this shell's Laptop panel included). Widen it to
  # world-readable — it's a monotonic counter, nothing sensitive.
  services.udev.extraRules = ''
    SUBSYSTEM=="powercap", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod 0444 /sys%p/energy_uj"
    SUBSYSTEM=="leds", KERNEL=="rgb:kbd_backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys%p/brightness /sys%p/multi_intensity", RUN+="${pkgs.coreutils}/bin/chmod 0664 /sys%p/brightness /sys%p/multi_intensity"
  '';

  # Fan/keyboard-backlight EC driver for the Tongfang NP5x/NP6x/NP7x barebone
  # this laptop is built on (PCSpecialist just rebrands it — board name is
  # literally "NP5x_NP6x_NP7xPNP" per /sys/class/dmi/id/board_name). Verified
  # before enabling, rather than guessing: this is a 12th-gen CPU, which the
  # driver's own compatibility gate already grandfathers in regardless of
  # DMI vendor string, AND `/sys/bus/wmi/devices/` on this exact machine
  # already exposes ABBC0F6B/6C/6D-8EA1-11D1-..., which is precisely the
  # Clevo/Uniwill WMI GUID family `clevo_wmi`/`uniwill_wmi` bind to — so this
  # isn't a blind stab at unsupported hardware, the interface is confirmed
  # present. Should also be what's been missing for keyboard LED control.
  hardware.tuxedo-drivers.enable = true;

  # tailord: fan-curve / power-profile presets on top of tuxedo-drivers,
  # controllable via the `tailor` CLI (D-Bus service com.tux.Tailor) — this
  # is what the Laptop panel's presets actually call. tailor-gui is skipped
  # since the Quickshell panel is the UI for this.
  hardware.tuxedo-rs.enable = true;

  # Seed named fan curves + profiles matching the Laptop panel's presets.
  # tailord only ships a single "default" profile out of the box — these are
  # ADDITIONAL named files placed alongside it; `active_profile.json` and
  # `profiles/default.json`/`fan/default.json` are left alone since tailord
  # manages those itself (active_profile.json is a symlink it rewrites every
  # time you switch profiles). Curves are monotonic temp(°C)->fan(%) points;
  # the EC has its own independent thermal cutoffs regardless of what a
  # curve here requests, so there's no way to ask for something unsafe.
  environment.etc =
    let
      fanCurve = builtins.toJSON;
      # tailord auto-discovers every LED class device on the system and, for
      # any device not named in the active profile's `leds` list, drives it
      # with a hardcoded fallback animation (a red->green->blue loop) FOREVER
      # in its own background task — competing directly with the Quickshell
      # Laptop panel's own direct sysfs writes for keyboard color/rainbow
      # (this is what caused "picks a color, flashes it, reverts to
      # rainbow": tailord's loop was overwriting our write every few
      # seconds). Point every profile's `leds` entry at a keyboard-profile
      # of `ColorProfile::None` so tailord's LED runtime permanently backs
      # off this device and Quickshell is the only writer.
      # device_name/function values are read directly off this machine
      # (device/modalias since device/name doesn't exist for this platform
      # device, per tuxedo_sysfs's own fallback) — see
      # /sys/class/leds/rgb:kbd_backlight/device/modalias.
      kbdLedEntry = [
        {
          device_name = "platform:tuxedo_keyboard";
          function = "kbd_backlight";
          profile = "quickshell";
          mode = "Rgb";
        }
      ];
      profile = fanName: {
        fans = [ fanName ];
        leds = kbdLedEntry;
        performance_profile = null;
      };
    in
    {
      # ColorProfile::None — tailord's "don't touch this device" value.
      "tailord/keyboard/quickshell.json".text = builtins.toJSON "None";

      # tailord only auto-generates this once (gated on active_profile.json
      # not existing yet, which it already does on this machine) — Nix-manage
      # it from here on purely to add the `leds` override above; `fans` stays
      # exactly what tailord itself would have generated.
      "tailord/profiles/default.json".text = builtins.toJSON {
        fans = [ "default" ];
        leds = kbdLedEntry;
        performance_profile = null;
      };

      "tailord/fan/battery_saver.json".text = fanCurve [
        { temp = 30; fan = 0; }
        { temp = 45; fan = 15; }
        { temp = 55; fan = 25; }
        { temp = 65; fan = 35; }
        { temp = 75; fan = 50; }
        { temp = 85; fan = 70; }
        { temp = 95; fan = 100; }
      ];
      "tailord/fan/balanced.json".text = fanCurve [
        { temp = 25; fan = 0; }
        { temp = 30; fan = 10; }
        { temp = 40; fan = 22; }
        { temp = 50; fan = 35; }
        { temp = 60; fan = 45; }
        { temp = 70; fan = 62; }
        { temp = 80; fan = 75; }
        { temp = 90; fan = 100; }
      ];
      "tailord/fan/silent_beast.json".text = fanCurve [
        { temp = 30; fan = 0; }
        { temp = 40; fan = 8; }
        { temp = 50; fan = 18; }
        { temp = 60; fan = 30; }
        { temp = 70; fan = 45; }
        { temp = 80; fan = 65; }
        { temp = 90; fan = 100; }
      ];
      "tailord/fan/turbo.json".text = fanCurve [
        { temp = 20; fan = 20; }
        { temp = 30; fan = 35; }
        { temp = 40; fan = 45; }
        { temp = 50; fan = 55; }
        { temp = 60; fan = 70; }
        { temp = 70; fan = 85; }
        { temp = 80; fan = 100; }
      ];

      "tailord/profiles/battery_saver.json".text = builtins.toJSON (profile "battery_saver");
      "tailord/profiles/balanced.json".text = builtins.toJSON (profile "balanced");
      "tailord/profiles/silent_beast.json".text = builtins.toJSON (profile "silent_beast");
      "tailord/profiles/turbo.json".text = builtins.toJSON (profile "turbo");
    };

  # ---- System-wide packages (keep lean; user stuff goes in home/) ----
  environment.systemPackages = with pkgs; [
    git wget curl
    vim
  ];

  # ---- Fonts ----
  # Install Nerd Fonts explicitly (not just via Stylix) so the Quickshell bar
  # and every app can always find the icon glyphs. This fixes missing/blank
  # icons.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only   # icon glyphs as a fallback for any font
    inter
    noto-fonts
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
    sansSerif = [ "Inter" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # First install target. Once set, don't casually bump it.
  system.stateVersion = "25.11";

  # Raise file descriptor limits - Wayland 
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];
  systemd.settings.Manager.DefaultLimitNOFILE = 524288;
  systemd.user.settings.Manager.DefaultLimitNOFILE = 524288;
}

