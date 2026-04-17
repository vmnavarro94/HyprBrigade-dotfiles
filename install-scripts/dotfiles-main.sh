#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# HyprBrigade Dotfiles Installation #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_dotfiles.log"
CONFIG_SRC="$PARENT_DIR/configs"

backup_and_copy() {
  local name="$1"
  local src="$CONFIG_SRC/$name"
  local dst="$HOME/.config/$name"
  [ ! -d "$src" ] && return
  if [ -d "$dst" ]; then
    local bak="${dst}.bak.$(date +%H%M%S)"
    printf "${NOTE} Backing up ${YELLOW}$name${RESET} -> $(basename $bak)\n"
    mv "$dst" "$bak"
  fi
  cp -r "$src" "$dst"
  printf "${OK} ${YELLOW}$name${RESET} config installed.\n"
}

printf "\n%s - Copying ${SKY_BLUE}HyprBrigade configs${RESET}...\n" "${NOTE}"
for dir in hypr waybar wallust rofi kitty swaync wlogout btop cava fastfetch quickshell; do
  backup_and_copy "$dir"
done

# Copy wallpapers
printf "\n${NOTE} Copying ${SKY_BLUE}wallpapers${RESET}...\n"
# Use xdg-user-dir so the path matches WallpaperSelect.sh on any locale
xdg-user-dirs-update 2>/dev/null || true
PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
WALLPAPER_DIR="$PICTURES_DIR/wallpapers"
mkdir -p "$WALLPAPER_DIR"
cp -r "$PARENT_DIR/wallpapers/." "$WALLPAPER_DIR/"
printf "${OK} Wallpapers installed to ${YELLOW}$WALLPAPER_DIR${RESET}.\n"

# Generate wallust colors from default wallpaper
printf "\n${NOTE} Generating ${SKY_BLUE}color scheme${RESET} from wallpaper...\n"
WALLPAPER="$WALLPAPER_DIR/outer-wilds.webp"
mkdir -p "$HOME/.config/hypr/wallust"
if [ -f "$WALLPAPER" ] && command -v wallust &>/dev/null; then
  wallust run -s "$WALLPAPER" && printf "${OK} Color scheme generated.\n" || \
    printf "${WARN} wallust run failed. Using default colors.\n"
else
  printf "${WARN} Could not generate colors. Using defaults.\n"
fi
# Fallback: if wallust-hyprland.conf still doesn't exist, copy the default from repo
if [ ! -f "$HOME/.config/hypr/wallust/wallust-hyprland.conf" ]; then
  cp "$CONFIG_SRC/hypr/wallust/wallust-hyprland.conf" "$HOME/.config/hypr/wallust/" && \
    printf "${OK} Default wallust colors installed as fallback.\n"
fi

# Enable power-profiles-daemon
sudo systemctl enable power-profiles-daemon.service >>"$LOG" 2>&1 && \
  printf "${OK} power-profiles-daemon enabled.\n"

# Create wallpaper effects dir
mkdir -p "$HOME/.config/hypr/wallpaper_effects"

printf "\n%.0s" {1..2}
