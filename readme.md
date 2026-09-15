# Artix + Hyprland Desktop Recipe

An install recipe for a complete Artix desktop: [Artix Linux](https://artixlinux.org)
with [dinit](https://github.com/davmac314/dinit) as init, Hyprland on top, and
one theme gluing the whole thing together. One look, a handful of apps,
sensible defaults.

Once installed, the system reads as a plain hand-configured Artix install,
with stock session entries and bootloader settings throughout.

## What You Get

| Layer      | Choice                                                        |
| ---------- | ------------------------------------------------------------- |
| Base       | Artix Linux, dinit init, elogind, userspawn                     |
| Compositor | Hyprland (with hypridle, hyprlock, hyprpaper, hyprshot)        |
| Login      | SDDM (Qt6/QML greeter on Wayland via Weston kiosk, bundled Arc Dark theme) |
| Launchers  | rofi (`Ctrl+Space`, also `Alt+Space` / `Super+D`)              |
| Terminal   | alacritty (`Ctrl+Alt+T` or `Super+Return`)                     |
| Browsers   | ungoogled-chromium, librewolf                                  |
| Files      | thunar + gvfs, xarchiver archives, tumbler thumbnails          |
| Media      | ristretto (images), mpv (video), qpdfview (PDFs)               |
| Calculator | galculator                                                     |
| Shell      | zsh (default) with agnoster prompt, autosuggestions, syntax highlighting; dash as `/bin/sh`; bash kept for root |
| Editor     | vim (with a sane Arc Dark baseline config)                     |
| Theme      | Arc Dark GTK + Papirus(-Dark) icons, one coherent look         |
| Fonts      | CaskaydiaCove Nerd Font (mono), Adwaita Sans (UI)              |
| Audio      | pipewire + wireplumber + pipewire-pulse (dinit user services) + pipewire-jack, pavucontrol-qt mixer |
| Power/lock | wlogout menu, hyprlock, hypridle (10/15/30 min timeouts)       |
| Language   | 30-locale picker at install time (ISO locale preselected)      |
| Encryption | Optional LUKS2 (Argon2id) on the System partition; swap lives inside the encrypted volume as a Btrfs swapfile; one passphrase at boot |
| Firewall   | Optional ufw (dinit service) — default deny incoming, allow outgoing |

Everything else stays deliberately minimal.

## Repositories

Packages resolve in this order:

1. **Artix repos** (`system`, `world`, `galaxy`) — nearly everything,
   including all dinit service bundles (`*-dinit`).
2. **chaotic-aur** — only two packages: `ungoogled-chromium-bin`,
   `papirus-folders`.
3. **Arch `extra`** — last-ditch fallback, kept for anything Artix and chaotic
   lack at a given moment. Installed with `SigLevel = PackageRequired`.

## ISO Builds

A GitHub Actions workflow (`.github/workflows/build-iso.yml`) builds a custom
Artix dinit ISO with the installer script included. It runs daily, compares
the newest Artix ISO stamp at `iso.artixlinux.org` against existing releases
in the repo, and builds a new ISO only when upstream publishes a new one.
Finished ISOs land in the repo's Releases with sha256 checksums. The build
can also be triggered manually via `workflow_dispatch`.

The ISO profile lives in `iso-profile/desktop-recipe/` — a standard artools
profile (`profile.yaml` plus a `live-overlay/` tree) that installs the
Hyprland stack, SDDM with a bundled Arc Dark theme, the dinit service set, and ships the
installer at `/root/desktop-recipe/installer/recipe` inside the live session,
symlinked onto PATH as `recipe`.

A GitHub Pages site under `docs/` mirrors this readme as a landing page;
the deploy workflow (`.github/workflows/deploy-pages.yml`) publishes it on
every push that touches `docs/`.

## Install

Runs on any Artix live ISO — the custom one from Releases or a stock
`artix-base-dinit` ISO with the repo cloned onto it.

1. Download the latest ISO from the repo's Releases (built automatically
   against each new Artix release — see `## ISO Builds` above).
2. Write it to a USB stick and boot it.
3. Log in as the live user (password `artix`), open a terminal, and run:

```bash
sudo recipe
```

The installer asks for hostname, name, username, root/user passwords, system
language, timezone, and whether to enable LUKS2 encryption and the ufw
firewall, then partitions the selected disk as:

Unencrypted:

| # | Partition | Size     | FS     | Label  |
|---|-----------|----------|--------|--------|
| 1 | EFI       | 512 MiB  | FAT32  | BOOT   |
| 2 | Swap      | 4 GiB    | swap   | Swap   |
| 3 | Root      | rest     | Btrfs  | System (subvolumes `@` + `@home`) |

Encrypted (LUKS2, Argon2id):

| # | Partition | Size     | FS     | Label  |
|---|-----------|----------|--------|--------|
| 1 | EFI       | 512 MiB  | FAT32  | BOOT (unencrypted) |
| 2 | System    | rest     | LUKS2 → Btrfs | cryptsystem (subvolumes `@` + `@home`, 4 GiB swapfile inside) |

Then it bootstraps Artix + dinit (`basestrap`), installs the desktop, creates the user
(wheel/audio/video/storage + friends, sudo enabled), installs GRUB and
configures the Hyprland session via SDDM. With encryption on, the disk
passphrase is asked once at boot (initramfs `encrypt` hook) — the greeter
does not re-ask it.


## Keyboard Shortcuts

| Action            | Keys                    |
| ----------------- | ----------------------- |
| Launcher (rofi)   | `Ctrl+Space`, `Alt+Space`, `Super+D` |
| Browser           | `Super+Shift+B` (LibreWolf), `Super+B` (Chromium) |
| Files             | `Super+Shift+E`         |
| Screenshot region | `PrtSc` (full), `Shift+PrtSc` / `Super+Shift+S` |
| Lock screen       | `Super+L` (hyprlock)    |
| Power menu        | `Super+Shift+L` (wlogout) |
| Keybind cheatsheet | `Super+/` (rofi, live from `hyprctl binds`) |
| Clipboard history | `Super+V`               |
| Close window      | `Super+Q`               |
| Fullscreen        | `Super+F`               |
| Float window      | `Super+Shift+F`         |
| Focus             | `Super+H/J/K/L` or arrows |
| Workspaces        | `Super+1..9`, move with `Super+Shift+1..9` |
| Volume/Brightness | `XF86` media keys       |

## Layout

```
desktop-recipe/
├── installer/
│   └── recipe                   # bare-metal installer (runs in the live session)
├── packages/
│   ├── base.packages           # system + CLI package list
│   └── desktop.packages        # desktop package list
├── iso-profile/
│   └── desktop-recipe/         # artools profile for the GitHub Actions ISO build
├── system/
│   └── sddm/                   # sddm.conf (Wayland greeter), themes/arc-dark (QML theme)
├── conf/
│   ├── hypr/                   # hyprland.conf, autostart, monitors, hypridle, hyprlock, hyprpaper
│   ├── waybar/                 # config.jsonc + style.css
│   ├── alacritty/              # alacritty.toml (Arc Dark + CaskaydiaCove)
│   ├── rofi/                   # config.rasi
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
- ufw firewall (optional at install): default deny incoming / allow
  outgoing, IPv6 on, loopback + DHCP exempt. Enabled at boot by `ufw-dinit`.
- Wallpapers are from Pexels (free license, see `wallpapers/ATTRIBUTION.txt`).
- To change wallpaper: edit `~/.config/hypr/hyprpaper.conf` (and
  `~/.config/hypr/hyprlock.conf`), or swap `moraine-lake.jpg` for a different
  image from the set.

## License

[MIT](LICENSE)