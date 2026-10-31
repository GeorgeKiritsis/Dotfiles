#!/bin/bash
# usage: move-to-space.sh <space-index>  — moves focused window to that space and follows it
target="$1"
win=$(yabai -m query --windows --window) || exit 1
id=$(jq '.id' <<<"$win")
[ "$(jq '.space' <<<"$win")" = "$target" ] && exit 0

# Works when the scripting addition is loaded (SIP off)
yabai -m window "$id" --space "$target" 2>/dev/null
if [ "$(yabai -m query --windows --window "$id" | jq '.space')" = "$target" ]; then
  yabai -m space --focus "$target" 2>/dev/null || osascript -e "tell application \"System Events\" to key code $(echo 0 18 19 20 21 23 22 26 28 25 | cut -d' ' -f$((target+1))) using control down"
  exit 0
fi

# Fallback without SIP: drag window by title bar while switching desktop
x=$(jq '.frame.x + .frame.w / 2' <<<"$win")
y=$(jq '.frame.y + 12' <<<"$win")
"$HOME/.config/yabai/bin/drag-to-space" "$target" "$x" "$y"
