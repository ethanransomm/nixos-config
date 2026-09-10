{ config, pkgs, ... }:

{
  # Quickshell is now the notification daemon (see
  # home/quickshell/NotifStore.qml — it registers the org.freedesktop.Notifications
  # DBus service and backs the standalone Notification Centre panel + the
  # Battery panel's sidebar). Only one daemon can hold that DBus name, so
  # swaync stays disabled.
  services.swaync.enable = false;
}
