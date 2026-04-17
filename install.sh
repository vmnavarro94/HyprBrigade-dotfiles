#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# HyprBrigade - Arch Linux Install Script #

clear

OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

[ ! -d Install-Logs ] && mkdir Install-Logs
LOG="Install-Logs/install-$(date +%d-%H%M%S)_main.log"

# Must not run as root
if [[ $EUID -eq 0 ]]; then
  echo "${ERROR} Do not run as root. Exiting." | tee -a "$LOG"; exit 1
fi

# Check PulseAudio conflict
if pacman -Qq 2>/dev/null | grep -qw '^pulseaudio$'; then
  echo "${ERROR} PulseAudio detected. Uninstall it before running this script." | tee -a "$LOG"; exit 1
fi

# Ensure base-devel
if ! pacman -Q base-devel &>/dev/null; then
  sudo pacman -S --noconfirm base-devel || { echo "${ERROR} Failed to install base-devel. Exiting."; exit 1; }
fi

# Ensure whiptail
if ! command -v whiptail &>/dev/null; then
  sudo pacman -S --noconfirm libnewt
fi

# Ensure pciutils
if ! pacman -Qs pciutils &>/dev/null; then
  sudo pacman -S --noconfirm pciutils
fi

clear

printf "\n"
echo -e "\e[35m"
cat << "EOF"
 _   _             ____       _                 _
| | | |_   _ _ __ | __ ) _ __(_) __ _  __ _  __| | ___
| |_| | | | | '_ \|  _ \| '__| |/ _` |/ _` |/ _` |/ _ \
|  _  | |_| | |_) | |_) | |  | | (_| | (_| | (_| |  __/
|_| |_|\__, | .__/|____/|_|  |_|\__, |\__,_|\__,_|\___|
       |___/|_|                 |___/
EOF
echo -e "\e[0m"
printf "\n"

whiptail --title "HyprBrigade Install Script" \
  --msgbox "Welcome to HyprBrigade!\n\nhttps://github.com/vmnavarro94/HyprBrigade-dotfiles\n\nATTENTION: Run a full system update and reboot first (highly recommended).\n\nNOTE: If installing on a VM, enable 3D acceleration or Hyprland may not start." \
  15 80

if ! whiptail --title "Proceed?" --yesno "Ready to install HyprBrigade?" 7 50; then
  echo "${INFO} Installation cancelled."; exit 0
fi

# ── AUR helper ────────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
  aur_helper=$(whiptail --title "AUR Helper" --radiolist "Select an AUR helper:" 10 50 2 \
    "yay" "yay (recommended)" ON \
    "paru" "paru" OFF \
    3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && exit 0
  aur_helper=$(echo "$aur_helper" | tr -d '"')
else
  echo "${NOTE} AUR helper already installed."
fi

# ── NVIDIA detection ──────────────────────────────────────────────────────────
nvidia_detected=false
if lspci | grep -i "nvidia" &>/dev/null; then
  nvidia_detected=true
  whiptail --title "NVIDIA GPU Detected" \
    --msgbox "NVIDIA GPU detected.\n\nThe script can install nvidia-dkms and configure it if you choose." 10 60
fi

# ── Build options ─────────────────────────────────────────────────────────────
options_command=(
  whiptail --title "Select Options" --checklist \
  "Choose what to install\n(SPACEBAR to select, TAB to switch)" 28 80 18
)

if [ "$nvidia_detected" == "true" ]; then
  options_command+=(
    "nvidia"  "Configure NVIDIA GPU?" "OFF"
    "nouveau" "Blacklist Nouveau?" "OFF"
  )
fi

if ! groups "$(whoami)" | grep -q '\binput\b'; then
  options_command+=(
    "input_group" "Add user to input group (Waybar keyboard-state)?" "OFF"
  )
fi

options_command+=(
  "sddm"        "Install SDDM + HyprBrigade login theme?" "ON"
  "bluetooth"   "Configure Bluetooth?" "OFF"
  "thunar"      "Install Thunar file manager?" "ON"
  "zsh"         "Install zsh + Oh-My-Zsh?" "ON"
  "pokemon"     "Add Pokemon color scripts to terminal?" "ON"
  "dots"        "Install HyprBrigade dotfiles (configs)?" "ON"
)

while true; do
  selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && { echo "${INFO} Cancelled."; exit 0; }
  [ -z "$selected_options" ] && { whiptail --title "Warning" --msgbox "Select at least one option." 8 50; continue; }

  selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')
  IFS=' ' read -r -a options <<< "$selected_options"

  confirm_msg="You selected:\n\n"
  for opt in "${options[@]}"; do confirm_msg+=" • $opt\n"; done
  confirm_msg+="\nProceed?"

  if whiptail --title "Confirm" --yesno "$(printf "%s" "$confirm_msg")" 22 70; then
    break
  fi
done

# ── Script runner ─────────────────────────────────────────────────────────────
script_directory=install-scripts

execute_script() {
  local script="$script_directory/$1"
  if [ -f "$script" ]; then
    chmod +x "$script"
    env "$script"
  else
    echo "${WARN} Script '$1' not found."
  fi
}

# ── Base installation ─────────────────────────────────────────────────────────
execute_script "00-base.sh"
execute_script "pacman.sh"

if [ "$aur_helper" == "paru" ]; then
  execute_script "paru.sh"
else
  execute_script "yay.sh"
fi

execute_script "01-hypr-pkgs.sh"
execute_script "pipewire.sh"
execute_script "fonts.sh"
execute_script "hyprland.sh"

# ── Optional components ───────────────────────────────────────────────────────
for option in "${options[@]}"; do
  case "$option" in
    sddm)        execute_script "sddm.sh" ;;
    nvidia)      execute_script "nvidia.sh" ;;
    nouveau)     execute_script "nvidia_nouveau.sh" ;;
    bluetooth)   execute_script "bluetooth.sh" ;;
    input_group) execute_script "InputGroup.sh" ;;
    thunar)      execute_script "thunar.sh" ;;
    zsh)         execute_script "zsh.sh" ;;
    pokemon)     execute_script "zsh_pokemon.sh" ;;
    dots)        execute_script "dotfiles-main.sh" ;;
    *)           echo "Unknown option: $option" ;;
  esac
done

execute_script "02-Final-Check.sh"

clear
printf "\n${OK} HyprBrigade installation complete!\n"
printf "${NOTE} Log files saved in: Install-Logs/\n"
printf "\n${NOTE} If SDDM was not installed, start Hyprland by typing: ${SKY_BLUE}Hyprland${RESET}\n"
printf "${NOTE} It is highly recommended to ${YELLOW}reboot${RESET} your system.\n\n"
printf "${SKY_BLUE}  https://github.com/vmnavarro94/HyprBrigade-dotfiles${RESET}\n\n"

read -rp "${CAT} Reboot now? [y/N]: " reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
  systemctl reboot
fi
