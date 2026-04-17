#!/bin/bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */
# HyprBrigade - Arch Linux Hyprland Install Script

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root. Exiting."
    exit 1
fi

clear

# Colors
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET=$(tput sgr0)
ORANGE=$(tput setaf 166)
CYAN=$(tput setaf 6)

LOG="hyprbrigade-install-$(date +%d-%H%M%S).log"

display_banner() {
    cat << "EOF"
 _   _             ____       _                 _
| | | |_   _ _ __ | __ ) _ __(_) __ _  __ _  __| | ___
| |_| | | | | '_ \|  _ \| '__| |/ _` |/ _` |/ _` |/ _ \
|  _  | |_| | |_) | |_) | |  | | (_| | (_| | (_| |  __/
|_| |_|\__, | .__/|____/|_|  |_|\__, |\__,_|\__,_|\___|
       |___/|_|                 |___/
EOF
    echo ""
    printf "${CYAN}  https://github.com/vmnavarro94/HyprBrigade${RESET}\n\n"
}

display_banner

printf "${NOTE} This script will install HyprBrigade on Arch Linux.\n"
printf "${WARN} Make sure you have a fresh Arch installation before proceeding.\n\n"
sleep 2

# ── Check for yay ─────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    printf "${NOTE} yay not found. Installing yay...\n"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd -
fi

printf "${OK} yay is available.\n"

# ── Package lists ──────────────────────────────────────────────────────────────

# Hyprland ecosystem
hypr_pkgs=(
    hyprland
    xdg-desktop-portal-hyprland
    hyprlock
    hypridle
    hyprpolkitagent
    polkit
    polkit-qt6
    hyprcursor
)

# Wayland utilities
wayland_pkgs=(
    waybar
    swww
    wlogout
    swaync
    rofi
    swappy
    grim
    slurp
    wl-clipboard
    cliphist
    nwg-look
    nwg-displays
)

# Power management
power_pkgs=(
    upower
    power-profiles-daemon
    libsecret
)

# Terminal & shell
terminal_pkgs=(
    kitty
    lsd
    fastfetch
    btop
)

# Audio & media
media_pkgs=(
    pamixer
    playerctl
    pavucontrol
    mpv
    cava
)

# Fonts
font_pkgs=(
    ttf-jetbrains-mono-nerd
    otf-font-awesome
    otf-font-awesome-4
    ttf-droid
    ttf-fantasque-sans-mono
    noto-fonts
    noto-fonts-emoji
)

# Apps & utilities
app_pkgs=(
    wallust
    jq
    curl
    git
    python-requests
    brightnessctl
    network-manager-applet
    gvfs
    ffmpegthumbs
    viewnior
    qt5ct
    qt6ct
    ripgrep
    fd
)

# ── Install packages ───────────────────────────────────────────────────────────

install_pkg_group() {
    local group_name="$1"
    shift
    local pkgs=("$@")
    printf "\n${CAT} Installing $group_name...\n"
    if yay -S --needed --noconfirm "${pkgs[@]}" 2>&1 | tee -a "$LOG"; then
        printf "${OK} $group_name installed.\n"
    else
        printf "${ERROR} Some packages in $group_name failed. Check $LOG.\n"
    fi
}

install_pkg_group "Hyprland ecosystem" "${hypr_pkgs[@]}"
install_pkg_group "Wayland utilities"  "${wayland_pkgs[@]}"
install_pkg_group "Power management"   "${power_pkgs[@]}"
install_pkg_group "Terminal & shell"   "${terminal_pkgs[@]}"
install_pkg_group "Audio & media"      "${media_pkgs[@]}"
install_pkg_group "Fonts"              "${font_pkgs[@]}"
install_pkg_group "Apps & utilities"   "${app_pkgs[@]}"

# ── Optional: Bluetooth ────────────────────────────────────────────────────────
echo ""
read -rp "${CAT} Install Bluetooth support? (bluez, blueman) [y/N]: " bluetooth
if [[ "$bluetooth" =~ ^[Yy]$ ]]; then
    install_pkg_group "Bluetooth" bluez bluez-utils blueman
    sudo systemctl enable bluetooth.service
fi

# ── Optional: NVIDIA ───────────────────────────────────────────────────────────
echo ""
read -rp "${CAT} Install NVIDIA drivers (nvidia-dkms + utils)? [y/N]: " nvidia
if [[ "$nvidia" =~ ^[Yy]$ ]]; then
    install_pkg_group "NVIDIA" nvidia-dkms nvidia-utils lib32-nvidia-utils \
        libva-nvidia-driver linux-firmware-nvidia opencl-nvidia
fi

# ── Copy configs ───────────────────────────────────────────────────────────────
printf "\n${CAT} Copying HyprBrigade configs...\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/configs"

backup_and_copy() {
    local src="$CONFIG_SRC/$1"
    local dst="$HOME/.config/$1"
    if [ -d "$dst" ]; then
        printf "${NOTE} Backing up existing $1 -> $1.bak\n"
        mv "$dst" "${dst}.bak"
    fi
    cp -r "$src" "$dst"
    printf "${OK} $1 config installed.\n"
}

for dir in hypr waybar wallust rofi kitty swaync wlogout btop cava fastfetch; do
    [ -d "$CONFIG_SRC/$dir" ] && backup_and_copy "$dir"
done

# ── Copy wallpapers ────────────────────────────────────────────────────────────
printf "\n${CAT} Copying wallpapers...\n"
mkdir -p "$HOME/Pictures/wallpapers"
cp -r "$SCRIPT_DIR/wallpapers/." "$HOME/Pictures/wallpapers/"
printf "${OK} Wallpapers installed.\n"

# ── Enable services ────────────────────────────────────────────────────────────
printf "\n${CAT} Enabling system services...\n"
sudo systemctl enable power-profiles-daemon.service 2>/dev/null && \
    printf "${OK} power-profiles-daemon enabled.\n"

# ── Set initial wallpaper dir ──────────────────────────────────────────────────
mkdir -p "$HOME/.config/hypr/wallpaper_effects"

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
printf "${OK} HyprBrigade installation complete!\n"
printf "${NOTE} Log saved to: $LOG\n"
printf "${NOTE} Reboot or log out and select Hyprland to get started.\n\n"
printf "${CYAN}  https://github.com/vmnavarro94/HyprBrigade${RESET}\n\n"
