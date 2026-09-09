{ config, pkgs, ... }:

{
  # 32-bit libs for Steam/Proton, plus base graphics.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;          # required for Wayland/Hyprland
    powerManagement.enable = true;      # helps with suspend/resume on laptops
    open = false;                       # proprietary driver (RTX 30-series works best with this)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # ---- Hybrid graphics (Optimus) — laptop only ----
    # Your i7-12700H has an Intel iGPU + an NVIDIA dGPU. PRIME lets the iGPU
    # drive the display while the NVIDIA GPU handles heavy apps/games.
    #
    # FIND YOUR BUS IDs on the real machine:
    #     lspci | grep -E "VGA|3D"
    # Convert e.g. "00:02.0" -> "PCI:0:2:0" and "01:00.0" -> "PCI:1:0:0".
    prime = {
      # Offload mode: iGPU by default, NVIDIA on demand (best battery life).
      offload.enable = true;
      offload.enableOffloadCmd = true;   # gives you the `nvidia-offload` wrapper

      # Sync mode is an alternative (NVIDIA always on, better for constant gaming
      # but worse battery). Use ONE of offload or sync, not both.
      # sync.enable = true;

      intelBusId = "PCI:0:2:0";    # <-- REPLACE with yours
      nvidiaBusId = "PCI:1:0:0";   # <-- REPLACE with yours
    };
  };

  # To run a game on the NVIDIA GPU in offload mode, launch with:
  #     nvidia-offload <command>
  # or set it as a Steam launch option: nvidia-offload %command%
}
