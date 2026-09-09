# My NixOS config

Flake + Home Manager setup for a Hyprland laptop (i7-12700H, Intel+NVIDIA hybrid,
Zen kernel), themed with Stylix, with gaming and dev tooling built in.

## Structure

```
flake.nix                     # inputs (nixpkgs, home-manager, stylix) + outputs
hosts/laptop/
  configuration.nix           # host: identity, locale, imports the modules
  hardware-configuration.nix  # GENERATED per-machine — replace the placeholder
modules/system/
  boot.nix                    # systemd-boot (dual-boot Windows), Zen kernel
  nvidia.nix                  # PRIME hybrid graphics — set your bus IDs
  networking.nix              # NetworkManager, Bluetooth, PipeWire audio
  gaming.nix                  # Steam, gamescope, gamemode, Overwatch tweaks
modules/desktop/
  hyprland.nix                # enable compositor + SDDM + portals (system side)
  stylix.nix                  # one colorscheme -> whole system theming
home/
  home.nix                    # Home Manager entry, user packages
  programs/                   # your rice, as Nix: hyprland, waybar, kitty, shell, dev
  wallpapers/                 # drop wallpaper.jpg here
```

## Before you build — the placeholders to change

1. **Username**: replace `you` in `flake.nix`, `hosts/laptop/configuration.nix`,
   and `home/home.nix`.
2. **hardware-configuration.nix**: generate the real one on the machine with
   `sudo nixos-generate-config --root /mnt` (during install) and copy it in.
3. **NVIDIA bus IDs** in `modules/system/nvidia.nix`: run `lspci | grep -E "VGA|3D"`
   and convert to `PCI:x:y:z` format.
4. **Monitor line** in `home/programs/hyprland.nix`: run `hyprctl monitors`.
5. **Git name/email** in `home/programs/dev.nix`.
6. **Wallpaper**: put `wallpaper.jpg` in `home/wallpapers/`.
7. **stateVersion**: confirm it matches the NixOS version you're installing.

## Build

From this directory:

```bash
sudo nixos-rebuild switch --flake .#laptop
```

If a rebuild breaks the desktop, reboot and pick the previous generation from
the boot menu — nothing is ever unrecoverable.

## Migrating your existing rice gradually

Two honest ways to bring the ilyamiro dots across:

- **Fast**: in `home/programs/hyprland.nix`, use
  `extraConfig = builtins.readFile ./hyprland.conf;` and drop your existing
  file in. Same for other tools via `xdg.configFile`. Working desktop first.
- **Proper**: translate settings into the Nix DSL (as scaffolded here) piece by
  piece, so Stylix and Home Manager own them. Do this once things boot.

## Notes / gotchas

- Secure Boot: start with it **off** in BIOS to get NixOS booting alongside
  Windows. Revisit Lanzaboote later if you want it back.
- Hyprland switched to Lua config in v0.55 (May 2026); `hyprland.conf` still
  works for now but will be removed eventually. Home Manager supports Lua from
  the 26.05 release.
- Hyprland flake input recompiles on every update unless you set up Cachix.
  Starting with the nixpkgs Hyprland avoids that entirely.
```
