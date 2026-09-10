{ config, pkgs, ... }:

{
  # systemd-boot auto-detects Windows on the shared EFI partition, so both
  # appear in the boot menu. Do NOT let anything reformat the EFI partition.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Show other OSes (Windows) in the boot menu.
  boot.loader.systemd-boot.configurationLimit = 10;

  # Zen kernel — matches what you ran on Arch.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # NOTE ON SECURE BOOT:
  # If Windows has Secure Boot on, you'll likely need to disable it in BIOS
  # for NixOS to boot — OR set up Lanzaboote later to sign your boot files.
  # Start with Secure Boot off to get a working system, revisit later.
  # Keyboard layout lives in hosts/laptop/configuration.nix — don't duplicate
  # it here (it was previously set in both places, under the old renamed
  # xserver.layout/xkbVariant option names).
}
