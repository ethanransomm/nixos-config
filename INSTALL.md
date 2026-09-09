# Install guide — Ethan's Elimina IV 15 (kexec, no USB)

Tailored to YOUR disk. No placeholders — every device name below is yours,
verified via `findmnt`, `swapon`, `lsblk`, and `efibootmgr`.

## Your disk (confirmed)

| Part | What it is            | Role in install        | Formatted? |
|------|-----------------------|------------------------|------------|
| p1   | Windows ESP           | untouched              | NO         |
| p2   | Microsoft reserved    | untouched              | NO         |
| p3   | Windows C: (ntfs)     | untouched              | NO         |
| p4   | Windows recovery      | untouched              | NO         |
| p5   | Arch ESP (vfat)       | mount at /mnt/boot     | NO         |
| p6   | swap                  | swapon                 | NO         |
| p7   | Arch root (ext4)      | **reformat as NixOS**  | **YES**    |

`mkfs` runs on p7 and NOTHING ELSE. p5/p6 are reused as-is. p1–p4 never touched.

## Safety net (both confirmed)

- Backup on Google Drive, SHA256 verified re-downloadable (c6e2e232…ae15).
  → reachable from your phone after the wipe.
- Windows boots independently via F7 firmware menu; Secure Boot already off.

Worst case = reinstall Linux side. Never a bricked machine.

---

## Step 1 — In Arch: prep (non-destructive)

```bash
sudo pacman -S kexec-tools

# make sure config + backup are reachable from ANOTHER device (phone/cloud),
# because this machine is about to be wiped. Both are on Drive already.
```

Have on Drive/phone: your `nixos-config.tar.gz` and `arch-backup-…tar.gz`.

## Step 2 — kexec into the NixOS installer (commit point)

```bash
sudo -i
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

~6s later your kernel is replaced by the NixOS installer, running in RAM.
Arch is no longer running — but p7 still holds Arch's data until Step 4.
If anything feels wrong BEFORE Step 4, you can still reboot into Arch.

## Step 3 — Re-verify the disk (non-destructive, DO NOT SKIP)

Device names can occasionally reorder across kexec. Confirm before formatting:

```bash
lsblk -f
```

Check p7 is still the ext4 partition ~60% full (609G used), p5 the vfat ESP,
p6 swap. Only proceed if p7 is unmistakably your old Arch root.

## Step 4 — Format p7, mount p5 + p6 (the ONE destructive command)

```bash
# ⚠️ ERASES p7 (old Arch root). This is the only destructive line.
mkfs.ext4 -L nixos /dev/nvme0n1p7

mount /dev/disk/by-label/nixos /mnt

# existing Arch ESP → /boot. DO NOT format it (holds boot files, shared logic).
mkdir -p /mnt/boot
mount /dev/nvme0n1p5 /mnt/boot

# existing swap
swapon /dev/nvme0n1p6
```

There is exactly one `mkfs`, on p7. No `mkfs` on p5. Nothing touches
/dev/nvme0n1 as a whole (that would take Windows).

## Step 5 — Get your config + generate hardware config

```bash
# pull your repo from Drive (browser on phone → transfer, or gdown/rclone).
# say it lands at /root/nixos-config

nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
   /root/nixos-config/hosts/laptop/hardware-configuration.nix
```

Then fill these placeholders in the repo:

1. NVIDIA bus IDs — `lspci | grep -E "VGA|3D"` → convert to PCI:x:y:z in
   `modules/system/nvidia.nix` (e.g. 00:02.0 → PCI:0:2:0, 01:00.0 → PCI:1:0:0).
2. Git email in `home/programs/dev.nix`.
3. Wallpaper → `home/wallpapers/wallpaper.jpg` (dark navy/teal + warm accent).
4. Your fish + fastfetch from the backup:
   - unpack backup, copy `config/fish/config.fish` →
     `home/dotfiles/fish/config.fish`
   - copy `config/fastfetch/config.jsonc` →
     `home/dotfiles/fastfetch/config.jsonc`

Monitor line (`home/programs/hyprland.nix`) can wait — set it post-boot with
`hyprctl monitors`. The fallback works for first boot.

## Step 6 — Install + reboot

```bash
nix --extra-experimental-features "nix-command flakes" \
  run nixpkgs#nixos-install-tools -- nixos-install --root /mnt --flake /root/nixos-config#laptop
# set ethan's password when prompted
reboot
```

systemd-boot installs to p5 and auto-detects Windows on p1, so the boot menu
shows NixOS + Windows. The stale Arch GRUB entry (Boot0003) can be removed
later: `sudo efibootmgr -b 0003 -B`.

## Step 7 — First boot

Log in via SDDM → Hyprland. Keys: SUPER+Return kitty, SUPER+R rofi,
SUPER+Tab overview, SUPER+V clipboard, SUPER+L lock, SUPER+SHIFT+N notifs,
Waybar power icon → wlogout.

Ongoing: edit `~/nixos-config`, run `rebuild`. Broke the desktop? Reboot,
pick an older generation — nothing is unrecoverable.

## Step 8 — Bring your rice across (post-boot, unhurried)

Your backup has the full ilyamiro tree. Don't bulk-import it. Pull out just
YOUR keybinds from `config/hypr/custom/keybinds.conf` into the `bind = [ ]`
list (or `extraConfig`) in `home/programs/hyprland.nix`. Kitty/fish/fastfetch
already wired via `home/dotfiles/`.

---

## Troubleshooting

- **kexec installer misbehaves / hardware not re-initialised**: rare, but if
  it happens on the Elimina IV 15, stop — that's the sign a USB would be
  smoother. Non-destructive up to Step 4, so no loss.
- **Black screen after login**: NVIDIA bus IDs wrong, or try
  `WLR_NO_HARDWARE_CURSORS=1` (commented in modules/desktop/hyprland.nix).
- **hyprexpo won't open**: hyprland + hyprland-plugins inputs out of sync;
  check `nix flake metadata`.
- **Fonts show boxes**: log out/in so the Nerd Font cache refreshes.
- **Weather shows --**: wttr.in unreachable; retries every 15 min. Set your
  location in `home/programs/waybar.nix`.
