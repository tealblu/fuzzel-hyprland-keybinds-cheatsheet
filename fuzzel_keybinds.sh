#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# extract the keybindings from hyprland.conf
# format: "MOD + KEY<TAB>description<TAB>command"
mapfile -t BINDINGS < <(grep '^bind=' "$HYPR_CONF" | \
    sed -e 's/  */ /g' -e 's/bind=//g' -e 's/, /,/g' -e 's/ # /,/' | \
    awk -F, '{cmd=""; for(i=3;i<NF;i++) cmd=cmd $(i) " "; printf "%s + %s\t%s\t%s\n", $1, $2, $NF, cmd}')

CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | fuzzel --dmenu --prompt="Hyprland Keybinds: ")

# exit if no selection was made (e.g. user pressed ESC)
[[ -z "$CHOICE" ]] && exit 0

# extract cmd (3rd tab-separated field)
CMD=$(echo "$CHOICE" | cut -f3 | sed 's/[[:space:]]*$//')

# execute it if first word is exec else use hyprctl dispatch
if [[ $CMD == exec* ]]; then
    eval "$CMD"
else
    hyprctl dispatch "$CMD"
fi
