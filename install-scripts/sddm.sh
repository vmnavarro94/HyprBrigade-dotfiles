#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# SDDM Login Manager + HyprBrigade Theme #

sddm_pkgs=(
  qt6-declarative
  qt6-svg
  qt6-virtualkeyboard
  qt6-multimedia-ffmpeg
  qt5-quickcontrols2
  sddm
)

login=(
  lightdm gdm3 gdm lxdm lxdm-gtk3
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"

printf "${NOTE} Installing ${SKY_BLUE}SDDM and dependencies${RESET}...\n"
for pkg in "${sddm_pkgs[@]}"; do
  install_package "$pkg" "$LOG"
done

# Disable other login managers
for lm in "${login[@]}"; do
  if pacman -Qs "$lm" >/dev/null 2>&1; then
    sudo systemctl disable "$lm.service" >>"$LOG" 2>&1 || true
  fi
done

# Install HyprBrigade SDDM theme
printf "${NOTE} Installing ${SKY_BLUE}HyprBrigade SDDM theme${RESET}...\n"
sudo cp -r "$PARENT_DIR/sddm/hyprbrigade" /usr/share/sddm/themes/
sudo chmod -R 755 /usr/share/sddm/themes/hyprbrigade
sudo cp "$PARENT_DIR/sddm/sddm.conf" /etc/sddm.conf
printf "${OK} HyprBrigade SDDM theme installed.\n"

# Create wayland-sessions dir if missing
[ ! -d /usr/share/wayland-sessions ] && sudo mkdir -p /usr/share/wayland-sessions

printf "${INFO} Enabling ${SKY_BLUE}SDDM${RESET}...\n"
sudo systemctl enable sddm

printf "\n%.0s" {1..2}
