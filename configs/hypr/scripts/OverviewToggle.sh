#!/usr/bin/env bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */  #
# Workspace/Window overview using rofi

pkill rofi && exit 0 || true
rofi -show window \
  -theme "$HOME/.config/rofi/config.rasi" \
  -show-icons
