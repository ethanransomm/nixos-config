#!/usr/bin/env bash
# Back up the current Arch rice + system references before migrating to NixOS.
# Run as your normal user (NOT root). Copies to a timestamped folder + tarball.
set -euo pipefail

STAMP=$(date +%Y%m%d-%H%M%S)
DEST="$HOME/arch-backup-$STAMP"
mkdir -p "$DEST/config" "$DEST/home" "$DEST/system"

# --- rice + app configs ---
for d in hypr waybar rofi kitty fish fastfetch dunst mako swaync wlogout \
         gtk-3.0 gtk-4.0 nvim swww wal starship.toml; do
  [ -e "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" "$DEST/config/" 2>/dev/null || true
done

# --- themes, icons, fonts, wallpapers ---
for d in .themes .icons .local/share/fonts Pictures/wallpapers wallpapers; do
  [ -e "$HOME/$d" ] && cp -r "$HOME/$d" "$DEST/home/" 2>/dev/null || true
done

# --- shell + git dotfiles (fish included) ---
for f in .bashrc .zshrc .config/fish/config.fish .gitconfig; do
  [ -e "$HOME/$f" ] && cp "$HOME/$f" "$DEST/home/" 2>/dev/null || true
done

# --- system references (to read from, not restore) ---
pacman -Qqe > "$DEST/system/pkglist-explicit.txt" 2>/dev/null || true
pacman -Qq  > "$DEST/system/pkglist-all.txt" 2>/dev/null || true
cp /etc/fstab "$DEST/system/fstab.txt" 2>/dev/null || true
lsblk -f > "$DEST/system/lsblk.txt" 2>/dev/null || true
lspci | grep -E "VGA|3D" > "$DEST/system/gpu.txt" 2>/dev/null || true  # NVIDIA bus IDs

# --- SSH keys, separate + locked down (dirs 700, files 600) ---
if [ -d "$HOME/.ssh" ]; then
  cp -r "$HOME/.ssh" "$DEST/ssh-KEEP-SAFE"
  find "$DEST/ssh-KEEP-SAFE" -type d -exec chmod 700 {} + 2>/dev/null || true
  find "$DEST/ssh-KEEP-SAFE" -type f -exec chmod 600 {} + 2>/dev/null || true
fi

# --- compress ---
tar -czf "$HOME/arch-backup-$STAMP.tar.gz" -C "$HOME" "arch-backup-$STAMP"
echo "Backup written to: $HOME/arch-backup-$STAMP.tar.gz"
echo "Copy that .tar.gz to an EXTERNAL drive before installing NixOS."
