#!/bin/bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */
# HyprBrigade - Update Script

OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/configs"

echo ""
printf "${CYAN}  HyprBrigade Updater${RESET}\n"
printf "${CYAN}  https://github.com/vmnavarro94/HyprBrigade${RESET}\n\n"

# ── Pull latest from repo ──────────────────────────────────────────────────────
printf "${CAT} Pulling latest HyprBrigade changes...\n"
cd "$SCRIPT_DIR" && git pull origin main
printf "${OK} Repo up to date.\n\n"

# ── Update configs ─────────────────────────────────────────────────────────────
update_config() {
    local name="$1"
    local src="$CONFIG_SRC/$name"
    local dst="$HOME/.config/$name"

    [ ! -d "$src" ] && return

    read -rp "${CAT} Update $name config? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        if [ -d "$dst" ]; then
            printf "${NOTE} Backing up $name -> $name.bak\n"
            rm -rf "${dst}.bak"
            cp -r "$dst" "${dst}.bak"
        fi
        cp -r "$src" "$dst"
        printf "${OK} $name updated.\n"
    fi
}

for dir in hypr waybar wallust rofi kitty swaync wlogout btop cava fastfetch; do
    update_config "$dir"
done

# ── Update .zshrc ──────────────────────────────────────────────────────────────
if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    read -rp "${CAT} Update .zshrc? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak" 2>/dev/null || true
        cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
        printf "${OK} .zshrc updated.\n"
    fi
fi

# ── Reload running services ────────────────────────────────────────────────────
printf "\n${CAT} Reloading Waybar and Hyprland...\n"

if pidof waybar >/dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || true
    printf "${OK} Waybar reloaded.\n"
fi

if command -v hyprctl &>/dev/null; then
    hyprctl reload 2>/dev/null || true
    printf "${OK} Hyprland reloaded.\n"
fi

echo ""
printf "${OK} HyprBrigade update complete!\n\n"
