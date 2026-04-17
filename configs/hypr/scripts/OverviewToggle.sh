#!/usr/bin/env bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */  #
# Overview toggle wrapper - tries Quickshell first, falls back to rofi

set -euo pipefail

# 1) Try Quickshell via IPC (works if QS is running and listening)
if pgrep -x quickshell >/dev/null 2>&1; then
  if qs ipc -c overview call overview toggle >/dev/null 2>&1; then
    exit 0
  fi
fi

# If QS isn't running, but the CLI exists, try starting it and retry once
if command -v qs >/dev/null 2>&1; then
  qs -c overview >/dev/null 2>&1 &
  sleep 0.6
  if qs ipc -c overview call overview toggle >/dev/null 2>&1; then
    exit 0
  fi
fi

# 2) Fall back to rofi window switcher
pkill rofi && exit 0 || true
rofi -show window \
  -theme "$HOME/.config/rofi/config.rasi" \
  -show-icons
