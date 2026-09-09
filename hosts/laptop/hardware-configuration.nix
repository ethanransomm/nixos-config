# =====================================================================
# PLACEHOLDER — DO NOT USE AS-IS.
#
# This file MUST be generated on your actual machine. It describes your
# real disks, partitions (UUIDs), and detected kernel modules. Copying
# someone else's will fail to boot.
#
# To generate it during install:
#     sudo nixos-generate-config --root /mnt
# then copy /mnt/etc/nixos/hardware-configuration.nix over this file.
#
# Or on an already-running NixOS:
#     nixos-generate-config --show-hardware-config > hardware-configuration.nix
# =====================================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # These are EXAMPLES ONLY — yours will differ.
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # fileSystems."/" = { device = "/dev/disk/by-uuid/REPLACE-ME"; fsType = "ext4"; };
  # fileSystems."/boot" = { device = "/dev/disk/by-uuid/REPLACE-ME"; fsType = "vfat"; };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
