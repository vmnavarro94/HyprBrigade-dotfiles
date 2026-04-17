#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# Hyprland Packages #

hypr_package=(
  awww
  bc
  cliphist
  curl
  grim
  gvfs
  gvfs-mtp
  hyprpolkitagent
  imagemagick
  inxi
  jq
  kitty
  kvantum
  libspng
  libnotify
  nano
  network-manager-applet
  pamixer
  pavucontrol
  playerctl
  python-requests
  python-pyquery
  qt5ct
  qt6ct
  qt6-svg
  rofi
  slurp
  swappy
  swaync
  wallust
  waybar
  wget
  wl-clipboard
  wlogout
  xdg-user-dirs
  xdg-utils
  yad
)

hypr_package_2=(
  brightnessctl
  btop
  cava
  loupe
  fastfetch
  gnome-system-monitor
  mousepad
  mpv
  mpv-mpris
  nvtop
  nwg-look
  nwg-displays
  pacman-contrib
  power-profiles-daemon
  qalculate-gtk
  unzip
  yt-dlp
)

# Packages to remove as they conflict
uninstall=(
  dunst
  mako
  rofi-lbonn-wayland
  rofi-lbonn-wayland-git
  wallust-git
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

printf "\n%s - ${SKY_BLUE}Removing conflicting packages${RESET}...\n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
done

printf "\n%s - Installing ${SKY_BLUE}HyprBrigade necessary packages${RESET}...\n" "${NOTE}"
for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}
