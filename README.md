<div align="center">

# 🪖 HyprBrigade

**A Hyprland dotfiles setup for Arch Linux**

[![Hyprland](https://img.shields.io/badge/Hyprland-0.54-blue?style=flat-square)](https://hyprland.org)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=flat-square&logo=arch-linux)](https://archlinux.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## Components

| Role | Package |
|---|---|
| Compositor | [Hyprland](https://hyprland.org) |
| Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Launcher | [Rofi](https://github.com/davatorium/rofi) |
| Notifications | [swaync](https://github.com/ErikReider/SwayNotificationCenter) |
| Wallpaper | [swww](https://github.com/LGFae/swww) |
| Color scheme | [wallust](https://codeberg.org/explosion-mental/wallust) |
| Lock screen | [hyprlock](https://github.com/hyprwm/hyprlock) |
| Idle daemon | [hypridle](https://github.com/hyprwm/hypridle) |
| Logout menu | [wlogout](https://github.com/ArtsyMacaw/wlogout) |

---

## Installation

> **Requirements:** Arch Linux with an AUR helper (`yay`). If you don't have `yay`, the script will install it automatically.

```bash
git clone https://github.com/vmnavarro94/HyprBrigade-dotfiles.git
cd HyprBrigade-dotfiles
chmod +x install.sh
./install.sh
```

The script will:
1. Install all required packages via `yay`
2. Ask if you want Bluetooth and/or NVIDIA drivers
3. Copy all configs to `~/.config/`
4. Back up any existing configs with a `.bak` suffix
5. Enable required system services

After installation, reboot and select **Hyprland** from your display manager.

---

## Wallpapers

Wallpapers are included in the `wallpapers/` folder and will be copied to `~/Pictures/wallpapers/`.

Color schemes are generated automatically from your active wallpaper using [wallust](https://codeberg.org/explosion-mental/wallust), applying consistently across Waybar, Hyprlock, Rofi, Kitty, and swaync.

---

## Key Bindings

| Shortcut | Action |
|---|---|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + E` | File manager |
| `SUPER + R` | App launcher (Rofi) |
| `SUPER + Q` | Close window |
| `SUPER + SHIFT + E` | Quick settings menu |
| `SUPER + L` | Lock screen |
| `SUPER + 1-9` | Switch workspace |
| `Print` | Screenshot |

---

## Power Management

The power button in the top bar opens **wlogout** with options for lock, suspend, reboot, shutdown, logout, and hibernate — all working out of the box without password prompts.

Requires `polkit`, `hyprpolkitagent`, `upower`, and `power-profiles-daemon` — all installed automatically by the install script.

---

## NVIDIA

During installation you will be asked if you want to install NVIDIA drivers. This installs `nvidia-dkms`, `nvidia-utils`, `lib32-nvidia-utils`, `libva-nvidia-driver`, and `linux-firmware-nvidia`.

---

## License

MIT — do whatever you want with it.
