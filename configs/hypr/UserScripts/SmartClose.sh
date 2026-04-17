#!/usr/bin/env bash
# /* ---- 💫 https://github.com/vmnavarro94/HyprBrigade 💫 ---- */  #
# SmartClose: If the focused window is the dropdown terminal, hide it.
# Otherwise, kill the active window normally.

ADDR_FILE="/tmp/dropdown_terminal_addr"
SPECIAL_WS="special:scratchpad"
SLIDE_STEPS=5

animate_slide_up() {
  local addr="$1" start_x="$2" start_y="$3" width="$4" height="$5"
  local end_y=$((start_y - height - 50))
  local step_y=$(((start_y - end_y) / SLIDE_STEPS))
  for i in $(seq 1 $SLIDE_STEPS); do
    local current_y=$((start_y - (step_y * i)))
    hyprctl dispatch movewindowpixel "exact $start_x $current_y,address:$addr" >/dev/null 2>&1
    sleep 0.03
  done
}

# Get focused window address
focused_addr=$(hyprctl activewindow -j | jq -r '.address // empty')

# Get stored dropdown terminal address
dropdown_addr=""
if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
  dropdown_addr=$(cut -d' ' -f1 "$ADDR_FILE")
fi

if [ -n "$dropdown_addr" ] && [ "$focused_addr" = "$dropdown_addr" ]; then
  # Focused window IS the dropdown — hide it with the same slide-up animation
  geometry=$(hyprctl clients -j | jq -r --arg ADDR "$focused_addr" \
    '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"')
  if [ -n "$geometry" ]; then
    curr_x=$(echo $geometry | cut -d' ' -f1)
    curr_y=$(echo $geometry | cut -d' ' -f2)
    curr_width=$(echo $geometry | cut -d' ' -f3)
    curr_height=$(echo $geometry | cut -d' ' -f4)
    animate_slide_up "$focused_addr" "$curr_x" "$curr_y" "$curr_width" "$curr_height"
    sleep 0.1
  fi
  hyprctl dispatch pin "address:$focused_addr"  # unpin (toggle)
  hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$focused_addr"
else
  hyprctl dispatch killactive
fi
