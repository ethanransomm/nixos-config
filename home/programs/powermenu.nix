{ config, pkgs, ... }:

{
  # The Power panel (home/quickshell/panels/Power.qml) and the Battery
  # panel's 2x2 grid now cover lock/suspend/reboot/shutdown/logout natively,
  # so wlogout is retired.

  # Bluetooth applet in the tray — kept as a full pairing-wizard fallback;
  # the bar's Bluetooth panel handles connect/reconnect/discovery but not
  # the PIN-entry pairing flow for brand-new devices.
  services.blueman-applet.enable = true;
}
