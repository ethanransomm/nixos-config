{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  # Bluetooth (laptop).
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Audio via PipeWire (the modern default; replaces PulseAudio).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
