#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# XDG Desktop Portals for Hyprland #
# Required for screensharing and file dialogs in Wayland apps #

xdg=(
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  umockdev
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_xdph.log"

printf "${NOTE} Installing ${SKY_BLUE}XDG Desktop Portals${RESET} (screenshare + file dialogs)...\n"
for PKG in "${xdg[@]}"; do
  install_package "$PKG" "$LOG"
done

printf "\n%.0s" {1..2}
