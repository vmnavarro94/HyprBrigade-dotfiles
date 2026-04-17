#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# Disk Space Monitor - Low Disk Notifications #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_disk-monitor.log"

# libnotify already installed as a base package
DISK_SCRIPT="$HOME/.config/hypr/scripts/disk-monitor.sh"
mkdir -p "$HOME/.config/hypr/scripts"

cat > "$DISK_SCRIPT" << 'EOF'
#!/bin/bash
# Disk Space Monitoring Script
DISK_WARNING_THRESHOLD=80
DISK_CRITICAL_THRESHOLD=90
CHECK_INTERVAL=300

declare -A NOTIFIED_WARNING
declare -A NOTIFIED_CRITICAL

while true; do
    df -h | grep '^/dev/' | while read -r line; do
        DEVICE=$(echo "$line" | awk '{print $1}')
        MOUNT=$(echo "$line" | awk '{print $6}')
        USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')

        [[ "$USAGE" =~ ^[0-9]+$ ]] || continue

        if [ "$USAGE" -ge "$DISK_CRITICAL_THRESHOLD" ]; then
            if [ "${NOTIFIED_CRITICAL[$MOUNT]}" != "true" ]; then
                notify-send -u critical -i drive-harddisk "Critical Disk Space" "$MOUNT is ${USAGE}% full!\nDevice: $DEVICE"
                NOTIFIED_CRITICAL[$MOUNT]="true"
                NOTIFIED_WARNING[$MOUNT]="true"
            fi
        elif [ "$USAGE" -ge "$DISK_WARNING_THRESHOLD" ]; then
            if [ "${NOTIFIED_WARNING[$MOUNT]}" != "true" ]; then
                notify-send -u normal -i drive-harddisk "Low Disk Space" "$MOUNT is ${USAGE}% full\nDevice: $DEVICE"
                NOTIFIED_WARNING[$MOUNT]="true"
            fi
        else
            if [ "$USAGE" -lt $((DISK_WARNING_THRESHOLD - 5)) ]; then
                NOTIFIED_WARNING[$MOUNT]="false"
                NOTIFIED_CRITICAL[$MOUNT]="false"
            fi
        fi
    done
    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$DISK_SCRIPT"
printf "${OK} Disk monitoring script created.\n"

SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

cat > "$SYSTEMD_DIR/disk-monitor.service" << EOF
[Unit]
Description=Disk Space Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=$DISK_SCRIPT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable disk-monitor.service 2>&1 | tee -a "$LOG"
systemctl --user start disk-monitor.service 2>&1 | tee -a "$LOG"
printf "${OK} Disk monitor service enabled and started.\n"

printf "\n%.0s" {1..2}
