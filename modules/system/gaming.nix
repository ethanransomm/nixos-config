{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;   # lets you launch Steam in a gamescope session
    remotePlay.openFirewall = true;
  };

  programs.gamemode.enable = true;    # `gamemoderun %command%` in Steam launch opts

  environment.systemPackages = with pkgs; [
    gamescope        # micro-compositor for better frame pacing (fixes Overwatch stutter)
    mangohud         # in-game FPS/perf overlay
    protonup-qt      # manage Proton-GE versions
    lutris           # for Battle.net / Overwatch outside Steam if needed
  ];

  # From your Arch tuning — Overwatch/Source-engine games want a high map count.
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  # Recommended Overwatch launch options (set per-game in Steam):
  #   gamemoderun gamescope -f -w 1920 -h 1080 -r 144 -- %command%
  # On the NVIDIA GPU add the offload wrapper:
  #   nvidia-offload gamemoderun gamescope ... -- %command%
}
