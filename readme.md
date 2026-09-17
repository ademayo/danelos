# Artix + Hyprland Desktop Recipe

An install recipe for a complete Artix desktop: [Artix Linux](https://artixlinux.org)
with [dinit](https://github.com/davmac314/dinit) as init, Hyprland on top, and
one theme gluing it together. One look, a handful of apps, sensible defaults.

The result reads as a plain hand-configured Artix install.

## What You Get

| Layer           | Choice                                                                                                   |
| --------------- | -------------------------------------------------------------------------------------------------------- |
| Base            | Artix Linux, dinit init, elogind, userspawn                                                              |
| Compositor      | Hyprland (with hypridle, hyprlock, hyprpaper, hyprshot)                                                  |
| Login           | greetd + tuigreet (TUI greeter launches Hyprland directly)                                             |
| Launchers       | quickshell launcher (`Ctrl+Space`, also `Alt+Space` / `Super+D`)                                         |
| Bar / Indicators| quickshell bar + tray applets (nm-applet, pasystray, blueman-applet, cbatticon)                          |
| Terminal        | ghostty (`Ctrl+Alt+T` or `Super+Return`)                                                                 |
| Browsers / Mail | ungoogled-chromium, librewolf, betterbird-bin                                                            |
| Files           | dolphin + dolphin-plugins + kio-extras (file manager)                                                    |
| Media           | gwenview (images), mpv (video), qpdfview (PDFs)                                                        |
| Shell           | zsh (default) with agnoster prompt, autosuggestions, syntax highlighting; dash as `/bin/sh`; bash kept for root |
| Editor          | vim (with a sane Arc Dark baseline config)                                                               |
| Theme           | Arc Dark across GTK and Qt; custom Qt6ct palette matching Arc Dark; Papirus(-Dark) icons                 |
| Fonts           | CaskaydiaCove Nerd Font (mono), Adwaita Sans (UI)                                                        |
| Audio           | pipewire + wireplumber + pipewire-pulse (dinit user services) + pipewire-jack, pavucontrol-qt mixer       |
| Power/lock      | wlogout menu, hyprlock, hypridle (10/15/30 min timeouts)                                                 |
| Language        | Locale/timezone/keymap already configured on the base system                                             |
| Encryption      | Handled by your existing base install; this layer does not touch disks or bootloaders                    |
| Firewall        | Mandatory ufw (dinit service) — default deny incoming, allow outgoing                                    |

Everything else stays deliberately minimal.

## Repositories

Packages resolve in this order:

1. **Artix repos** (`system`, `world`, `galaxy`) — nearly everything,
   including all dinit service bundles (`*-dinit`).
2. **chaotic-aur** — `papirus-folders` and any AUR-only `-bin` packages.
3. **Arch `extra`** — last-ditch fallback, kept for anything Artix and chaotic
   lack at a given moment. Installed with `SigLevel = PackageRequired`.

## Install

Assumes an already-installed Artix base system with **dinit** init and the
**Chaotic-AUR** repo configured. Run as root:

```bash
git clone https://github.com/ademayo/danelos.git
sudo ./danelos/installer/recipe
```

The installer asks for the target username (must already exist), then installs
desktop packages, enables dinit services, deploys configs, sets `zsh` as the
login shell, and enables the ufw firewall.

The `greetd` service is enabled automatically. If you want Plymouth, you must
manually add `plymouth` to `HOOKS` in `/etc/mkinitcpio.conf`, add `quiet splash`
to `GRUB_CMDLINE_LINUX_DEFAULT`, regenerate initramfs and GRUB config, then
reboot.

## Keyboard Shortcuts

| Action                | Keys                                                |
| --------------------- | --------------------------------------------------- |
| Launcher (quickshell) | `Ctrl+Space`, `Alt+Space`, `Super+D`                |
| Browser               | `Super+Shift+B` (LibreWolf), `Super+B` (Chromium)   |
| Mail                  | `Super+Shift+M` (Betterbird)                        |
| Files                 | `Super+Shift+E`                                     |
| Screenshot region     | `PrtSc` (full), `Shift+PrtSc` / `Super+Shift+S`     |
| Lock screen           | `Super+L` (hyprlock)                                |
| Power menu            | `Super+Shift+L` (wlogout)                           |
| Keybind cheatsheet    | `Super+/` (fuzzel, live from `hyprctl binds`)       |
| Clipboard history     | `Super+V` (fuzzel + cliphist)                       |
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
│   └── recipe                  # desktop layer installer (runs on installed Artix)
├── packages/
│   └── desktop.packages        # desktop package list
├── system/
│   ├── greetd/                 # greetd + tuigreet config (TUI greeter → Hyprland)
│   └── tlp/                    # laptop power settings
├── conf/
│   ├── hypr/                   # hyprland.conf, autostart, monitors, hypridle, hyprlock, hyprpaper
│   ├── quickshell/             # shell.qml (bar) + launcher.qml (app launcher)
│   ├── ghostty/                # config (Arc Dark + CaskaydiaCove)
│   ├── wlogout/                # layout.json + style.css
│   ├── gtk/                    # gtk-3.0/settings.ini, gtk-4.0/settings.ini, Xresources
│   ├── qt/                     # qt6ct.conf + colors/
│   ├── bin/                    # keybind-cheatsheet
│   ├── zsh/zshrc               # agnoster-style prompt + omz-like features
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
- `greetd` (greetd-dinit) — login manager with tuigreet TUI greeter
- `userspawn` (userspawn-dinit) — starts `dinit --user` on login

User services (via userspawn): `dbus`, `pipewire`, `pipewire-pulse`,
`wireplumber`.

## Notes

- Greeter: tuigreet TUI on greetd; config at `/etc/greetd/config.toml`.
  Hyprland is launched directly after login.
- ufw is enabled at boot: default deny incoming, allow outgoing, IPv6 on,
  loopback + DHCP exempt.
- Wallpapers are from Pexels (free license, see `wallpapers/ATTRIBUTION.txt`).
  Swap `moraine-lake.jpg` for another image in the set, or edit
  `~/.config/hypr/hyprpaper.conf`.

### Laptops

Laptop support is baked in:

- `tlp` at boot with `USB_AUTOSUSPEND=0` so USB devices stay powered on battery.
- Battery charge thresholds set to 75–80% via `tpacpi-bat`.
- `conf/hypr/laptop.conf`: touchpad disable-while-typing, TrackPoint middle
  button, three-finger workspace swipe, Lenovo function keys.
- Optional fingerprint login: enroll with `fprintd-enroll`, then wire
  `greetd`/`tuigreet` to PAM if desired.
- The T490's 1080p panel does not need fractional scaling. Set scale in
  `~/.config/hypr/monitors.conf` if you want larger UI.

## License

[MIT](LICENSE)