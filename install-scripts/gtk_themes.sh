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

printf "${NOTE} Installing ${SKY_BLUE}GTK engine packages${RESET}...\n"
for PKG in "${engine[@]}"; do
  install_package "$PKG" "$LOG"
done

# Remove old directory if present
if [ -d "GTK-themes-icons" ]; then
  printf "${NOTE} Removing old GTK-themes-icons directory...\n"
  rm -rf "GTK-themes-icons"
fi

printf "${NOTE} Downloading ${SKY_BLUE}GTK Themes & Icons${RESET}...\n"
if git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git 2>&1 | tee -a "$LOG"; then
  mkdir -p ~/.icons ~/.themes

  # Extract GTK themes
  for file in GTK-themes-icons/theme/*.tar.gz; do
    [ -f "$file" ] && tar -xzf "$file" -C ~/.themes --overwrite && \
      printf "${OK} Extracted $(basename $file)\n" || \
      printf "${WARN} Failed to extract $(basename $file)\n"
  done

  # Extract icon packs
  for file in GTK-themes-icons/icon/*.zip; do
    [ -f "$file" ] && unzip -o -q "$file" -d ~/.icons && \
      printf "${OK} Extracted $(basename $file)\n" || \
      printf "${WARN} Failed to extract $(basename $file)\n"
  done

  rm -rf GTK-themes-icons
  printf "${OK} GTK Themes & Icons installed.\n"
else
  printf "${ERROR} Failed to download GTK Themes & Icons.\n" | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
