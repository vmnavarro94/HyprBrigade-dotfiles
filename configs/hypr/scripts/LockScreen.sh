#!/usr/bin/env bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */  ##

# For Hyprlock
#pidof hyprlock || hyprlock -q

# Update weather cache in background (non-blocking)
bash "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1 &

loginctl lock-session

