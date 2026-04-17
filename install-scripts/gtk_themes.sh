#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# GTK Themes & Icons #

engine=(
  unzip
  gtk-engine-murrine
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_gtk-themes.log"
GTK_SRC="$PARENT_DIR/GTK-themes-icons"

printf "${NOTE} Installing ${SKY_BLUE}GTK engine packages${RESET}...\n"
for PKG in "${engine[@]}"; do
  install_package "$PKG" "$LOG"
done

if [ ! -d "$GTK_SRC" ]; then
  printf "${ERROR} GTK-themes-icons folder not found in repo.\n" | tee -a "$LOG"
  exit 1
fi

mkdir -p ~/.icons ~/.themes

printf "${NOTE} Installing ${SKY_BLUE}GTK Themes${RESET}...\n"
for file in "$GTK_SRC/theme"/*.tar.gz; do
  [ -f "$file" ] && tar -xzf "$file" -C ~/.themes --overwrite && \
    printf "${OK} Extracted $(basename $file)\n" || \
    printf "${WARN} Failed to extract $(basename $file)\n"
done

printf "${NOTE} Installing ${SKY_BLUE}Icon Packs${RESET}...\n"
for file in "$GTK_SRC/icon"/*.zip; do
  [ -f "$file" ] && unzip -o -q "$file" -d ~/.icons && \
    printf "${OK} Extracted $(basename $file)\n" || \
    printf "${WARN} Failed to extract $(basename $file)\n"
done

printf "${OK} GTK Themes & Icons installed.\n"

printf "\n%.0s" {1..2}
