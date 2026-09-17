# Artix + Hyprland Desktop Recipe

An install recipe for a complete Artix desktop: [Artix Linux](https://artixlinux.org)
with [dinit](https://github.com/davmac314/dinit) as init, Hyprland on top, and
one theme gluing the whole thing together. One look, a handful of apps,
sensible defaults.

Once installed, the system reads as a plain hand-configured Artix install,
with stock session entries and bootloader settings throughout.

## What You Get

| Layer            | Choice                                                                                                   |
| ---------------- | -------------------------------------------------------------------------------------------------------- |
| Base             | Artix Linux, dinit init, elogind, userspawn                                                              |
| Compositor       | Hyprland (with hypridle, hyprlock, hyprpaper, hyprshot)                                                  |
| Login             | SDDM (Qt6/QML greeter on Wayland via Weston kiosk, bundled Arc Dark theme)                                |
| Launchers         | quickshell launcher (`Ctrl+Space`, also `Alt+Space` / `Super+D`)                                            |
| Bar / Indicators | quickshell bar + tray applets (nm-applet, pasystray, blueman-applet, xfce4-power-manager, nwg-clipman)    |
| Terminal          | ghostty (`Ctrl+Alt+T` or `Super+Return`)                                                                  |
| Browsers          | ungoogled-chromium, librewolf                                                                           |
| Files             | thunar + gvfs, xarchiver archives, tumbler thumbnails                                                   |
| Media             | ristretto (images), mpv (video), qpdfview (PDFs)                                                        |
| Calculator        | galculator                                                                                              |
| Shell             | zsh (default) with agnoster prompt, autosuggestions, syntax highlighting; dash as `/bin/sh`; bash kept for root |
| Editor            | vim (with a sane Arc Dark baseline config)                                                              |
| Theme             | Arc Dark GTK + Papirus(-Dark) icons, one coherent look                                                  |
| Fonts             | CaskaydiaCove Nerd Font (mono), Adwaita Sans (UI)                                                       |
| Audio             | pipewire + wireplumber + pipewire-pulse (dinit user services) + pipewire-jack, pavucontrol-qt mixer       |
| Power/lock        | wlogout menu, hyprlock, hypridle (10/15/30 min timeouts)                                                  |
| Language          | 30-locale picker at install time (ISO locale preselected)                                               |
| Encryption        | Mandatory LUKS2 on the System partition; swap is an encrypted Btrfs 4 GiB swapfile; one passphrase at boot |
| Firewall          | Mandatory ufw (dinit service) — default deny incoming, allow outgoing                                   |

Everything else stays deliberately minimal.

## Repositories

Packages resolve in this order:

1. **Artix repos** (`system`, `world`, `galaxy`) — nearly everything,
   including all dinit service bundles (`*-dinit`).
2. **chaotic-aur** — only two packages: `ungoogled-chromium-bin`,
   `papirus-folders`.
3. **Arch `extra`** — last-ditch fallback, kept for anything Artix and chaotic
   lack at a given moment. Installed with `SigLevel = PackageRequired`.

## Install

You need a stock `artix-base-dinit` ISO and a network connection.

1. Download the ISO from [artixlinux.org](https://artixlinux.org/download.php)
   (base, dinit flavour) and write it to a USB stick.
2. Boot it and log in as the live user (password `artix`).
3. Connect to Wi-Fi (see below) or plug in Ethernet.
4. Open a terminal and run:

```bash
sudo pacman -Syu git --noconfirm

git clone https://github.com/ademayo/danelos.git
sudo ./danelos/installer/recipe
```

### Wi-Fi (wpa_supplicant)

The stock ISO ships no NetworkManager — bring the link up by hand first as root:

```bash
rfkill unblock all
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase 'MyNetwork' 'MyPassword')
dhcpcd wlan0
```

Replace `wlan0` with your interface (`ip link` or `ls /sys/class/net`). Once
`ping -c1 artixlinux.org` works, run the installer. Keep `wpa_supplicant` running
in the foreground in a second terminal if you prefer not to background it.

The installer asks for hostname, name, username, root/user passwords, system
language, timezone, and a disk passphrase (encryption is mandatory), then
partitions the selected disk as:

| # | Partition | Size     | FS     | Label  |
|---|-----------|----------|--------|--------|
| 1 | EFI       | 512 MiB  | FAT32  | BOOT (unencrypted) |
| 2 | System    | rest     | LUKS2 → Btrfs | cryptsystem (subvolumes `@` + `@home`, 4 GiB swapfile inside) |

Then it bootstraps Artix + dinit (`basestrap`), installs the desktop, creates the user
(wheel/audio/video/storage + friends, sudo enabled), installs GRUB and
configures the Hyprland session via SDDM. The disk passphrase is asked once
at boot (initramfs `encrypt` hook) — the greeter does not re-ask it.

## Keyboard Shortcuts

| Action                | Keys                                                |
| --------------------- | --------------------------------------------------- |
| Launcher (quickshell) | `Ctrl+Space`, `Alt+Space`, `Super+D`                |
| Browser               | `Super+Shift+B` (LibreWolf), `Super+B` (Chromium)   |
| Files                 | `Super+Shift+E`                                     |
| Screenshot region     | `PrtSc` (full), `Shift+PrtSc` / `Super+Shift+S`     |
| Lock screen           | `Super+L` (hyprlock)                                |
| Power menu            | `Super+Shift+L` (wlogout)                           |
| Keybind cheatsheet    | `Super+/` (fuzzel, live from `hyprctl binds`)       |
| Clipboard history | `Super+V` (nwg-clipman / fuzzel + cliphist fallback) |
| Close window          | `Super+Q`                                           |
| Fullscreen            | `Super+F`                                           |
| Float window          | `Super+Shift+F`                                     |
| Focus                 | `Super+H/J/K/L` or arrows                           |
| Workspaces            | `Super+1..9`, move with `Super+Shift+1..9`          |
| Volume/Brightness     | `XF86` media keys                                   |

## Layout

```
desktop-recipe/
├── installer/
│   └── recipe                   # bare-metal installer (runs in the live session)
├── packages/
│   ├── base.packages           # system + CLI package list
│   └── desktop.packages        # desktop package list
├── system/
│   └── sddm/                   # sddm.conf (Wayland greeter), themes/arc-dark (QML theme)
├── conf/
│   ├── hypr/                   # hyprland.conf, autostart, monitors, hypridle, hyprlock, hyprpaper
│   ├── quickshell/             # shell.qml (bar) + launcher.qml (app launcher)
│   ├── ghostty/                # config (Arc Dark + CaskaydiaCove)
│   ├── wlogout/                # layout.json + style.css
│   ├── gtk/                    # gtk-3.0/settings.ini, gtk-4.0/settings.ini
│   ├── qt/                     # qt6ct.conf
│   ├── zsh/zshrc                # agnoster-style prompt + omz-like features
│   └── vim/vimrc               # baseline vim config
└── wallpapers/                 # named photos (Pexels, see ATTRIBUTION.txt)
```

## dinit Services (System)

Enabled via `boot.d` symlinks by the installer:

- `NetworkManager` (networkmanager-dinit)
- `bluetoothd` (bluez-dinit)
- `avahi-daemon` (avahi-dinit)
- `sshd` (openssh-dinit)
- `cronie` (cronie-dinit)
- `sddm` (sddm-dinit) — login manager (Qt6/QML greeter on Weston kiosk)
- `userspawn` (userspawn-dinit) — starts `dinit --user` on login

User services (via userspawn): `dbus`, `pipewire`, `pipewire-pulse`,
`wireplumber`.

## Notes

- SDDM greeter runs its own Weston kiosk compositor (Wayland, no X server
  anywhere in the boot path); the Hyprland session starts per-user after
  login. Sessions come from `/usr/share/wayland-sessions` — any installed
  entry is selectable in the greeter's session dropdown.
- Greeter theme: bundled `system/sddm/themes/arc-dark` QML, palette-matched
  to the desktop (`#2b2e34` card, `#5294e2` steel-blue accent, `#383c43`
  fields). Overrides live in `/etc/sddm.conf.d/danelos.conf`.
- ufw firewall (mandatory at install): default deny incoming / allow
  outgoing, IPv6 on, loopback + DHCP exempt. Enabled at boot by `ufw-dinit`.
- Wallpapers are from Pexels (free license, see `wallpapers/ATTRIBUTION.txt`).
- To change wallpaper: edit `~/.config/hypr/hyprpaper.conf` (and
  `~/.config/hypr/hyprlock.conf`), or swap `moraine-lake.jpg` for a different
  image from the set.

###  Laptops

Laptop support is baked in:

- `tlp` is enabled at boot with `USB_AUTOSUSPEND=0`, so external USB
  keyboards, mice, and drives stay powered while on battery.
- Battery charge thresholds are set to 75–80% via `tpacpi-bat` to preserve
  cell health.
- `conf/hypr/laptop.conf` adds touchpad disable-while-typing, TrackPoint
  middle-button emulation, three-finger workspace swipe, and binds the
  Lenovo function keys (brightness, volume, mic mute, display, wifi,
  bluetooth).
- Fingerprint login is optional: `fprintd` is installed and can be enrolled
  after install with `fprintd-enroll`; SDDM will use it automatically once
  a print is registered.
- The T490's 1080p panel does not need fractional scaling; set your preferred
  scale in `~/.config/hypr/monitors.conf` if you want larger UI.

## License

[MIT](LICENSE)