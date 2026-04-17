#!/bin/bash
# 💫 https://github.com/vmnavarro94/HyprBrigade 💫 #
# Temperature Monitor - CPU/GPU Temperature Alerts #

temp=(
  lm_sensors
  libnotify
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

if ! source "$SCRIPT_DIR/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"; exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_temp-monitor.log"

printf "${NOTE} Installing ${SKY_BLUE}Temperature Monitor${RESET} packages...\n"
for PKG in "${temp[@]}"; do
  install_package "$PKG" "$LOG"
done

printf "${NOTE} Detecting ${YELLOW}hardware sensors${RESET}...\n"
sudo sensors-detect --auto 2>&1 | tee -a "$LOG"

TEMP_SCRIPT="$HOME/.config/hypr/scripts/temp-monitor.sh"
mkdir -p "$HOME/.config/hypr/scripts"

cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
# Temperature Monitoring Script
CPU_TEMP_WARNING=75
CPU_TEMP_CRITICAL=85
GPU_TEMP_WARNING=75
GPU_TEMP_CRITICAL=85
CHECK_INTERVAL=30

NOTIFIED_CPU_WARN=false
NOTIFIED_CPU_CRIT=false
NOTIFIED_GPU_WARN=false
NOTIFIED_GPU_CRIT=false

while true; do
    CPU_TEMP=$(sensors | grep -i 'Package id 0:\|Tdie:' | awk '{print $4}' | sed 's/+//;s/°C//' | head -1)
    [ -z "$CPU_TEMP" ] && CPU_TEMP=$(sensors | grep -i 'Core 0:' | awk '{print $3}' | sed 's/+//;s/°C//' | head -1)
    GPU_TEMP=$(sensors | grep -i 'edge:\|temp1:' | awk '{print $2}' | sed 's/+//;s/°C//' | head -1)

    if [ -n "$CPU_TEMP" ]; then
        CPU_INT=${CPU_TEMP%.*}
        if [ "$CPU_INT" -ge "$CPU_TEMP_CRITICAL" ] && [ "$NOTIFIED_CPU_CRIT" = false ]; then
            notify-send -u critical -i temperature-high "Critical CPU Temp" "CPU is ${CPU_TEMP}°C! System may throttle."
            NOTIFIED_CPU_CRIT=true; NOTIFIED_CPU_WARN=true
        elif [ "$CPU_INT" -ge "$CPU_TEMP_WARNING" ] && [ "$NOTIFIED_CPU_WARN" = false ]; then
            notify-send -u normal -i temperature-normal "High CPU Temp" "CPU is ${CPU_TEMP}°C"
            NOTIFIED_CPU_WARN=true
        elif [ "$CPU_INT" -lt "$CPU_TEMP_WARNING" ]; then
            NOTIFIED_CPU_WARN=false; NOTIFIED_CPU_CRIT=false
        fi
    fi

    if [ -n "$GPU_TEMP" ]; then
        GPU_INT=${GPU_TEMP%.*}
        if [ "$GPU_INT" -ge "$GPU_TEMP_CRITICAL" ] && [ "$NOTIFIED_GPU_CRIT" = false ]; then
            notify-send -u critical -i temperature-high "Critical GPU Temp" "GPU is ${GPU_TEMP}°C!"
            NOTIFIED_GPU_CRIT=true; NOTIFIED_GPU_WARN=true
        elif [ "$GPU_INT" -ge "$GPU_TEMP_WARNING" ] && [ "$NOTIFIED_GPU_WARN" = false ]; then
            notify-send -u normal -i temperature-normal "High GPU Temp" "GPU is ${GPU_TEMP}°C"
            NOTIFIED_GPU_WARN=true
        elif [ "$GPU_INT" -lt "$GPU_TEMP_WARNING" ]; then
            NOTIFIED_GPU_WARN=false; NOTIFIED_GPU_CRIT=false
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$TEMP_SCRIPT"
printf "${OK} Temperature monitoring script created.\n"

SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

cat > "$SYSTEMD_DIR/temp-monitor.service" << EOF
[Unit]
Description=Temperature Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=$TEMP_SCRIPT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable temp-monitor.service 2>&1 | tee -a "$LOG"
systemctl --user start temp-monitor.service 2>&1 | tee -a "$LOG"
printf "${OK} Temperature monitor service enabled and started.\n"

printf "\n%.0s" {1..2}
