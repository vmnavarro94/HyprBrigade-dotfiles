#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# Battery Monitor - Low Battery Notifications #

battery=(
  acpi
  libnotify
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_battery-monitor.log"

printf "${NOTE} Installing ${SKY_BLUE}Battery Monitor${RESET} packages...\n"
for PKG in "${battery[@]}"; do
  install_package "$PKG" "$LOG"
done

BATTERY_SCRIPT="$HOME/.config/hypr/scripts/battery-monitor.sh"
mkdir -p "$HOME/.config/hypr/scripts"

cat > "$BATTERY_SCRIPT" << 'EOF'
#!/bin/bash
# Low Battery Notification Script
LOW_BATTERY_THRESHOLD=20
CRITICAL_BATTERY_THRESHOLD=10
CHECK_INTERVAL=60

NOTIFIED_LOW=false
NOTIFIED_CRITICAL=false

while true; do
    BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
    BATTERY_STATUS=$(acpi -b | grep -o 'Discharging\|Charging\|Full')

    if [ "$BATTERY_STATUS" = "Discharging" ]; then
        if [ "$BATTERY_LEVEL" -le "$CRITICAL_BATTERY_THRESHOLD" ] && [ "$NOTIFIED_CRITICAL" = false ]; then
            notify-send -u critical -i battery-caution "Critical Battery" "Battery at ${BATTERY_LEVEL}%! Plug in your charger immediately."
            NOTIFIED_CRITICAL=true
            NOTIFIED_LOW=true
        elif [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ] && [ "$NOTIFIED_LOW" = false ]; then
            notify-send -u normal -i battery-low "Low Battery" "Battery at ${BATTERY_LEVEL}%. Consider plugging in."
            NOTIFIED_LOW=true
        fi
    else
        NOTIFIED_LOW=false
        NOTIFIED_CRITICAL=false
    fi

    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$BATTERY_SCRIPT"
printf "${OK} Battery monitoring script created.\n"

SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

cat > "$SYSTEMD_DIR/battery-monitor.service" << EOF
[Unit]
Description=Battery Level Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=$BATTERY_SCRIPT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable battery-monitor.service 2>&1 | tee -a "$LOG"
systemctl --user start battery-monitor.service 2>&1 | tee -a "$LOG"
printf "${OK} Battery monitor service enabled and started.\n"

printf "\n%.0s" {1..2}
