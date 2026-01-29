#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.wallpapers/"
WALL_LOC="$WALLPAPER_DIR/current_wallpaper"

# Get a random wallpaper that is not the current one
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$(readlink -e $WALL_LOC)")" | shuf -n 1)

# symlink somewhere
ln -sf $WALLPAPER $WALL_LOC

# Apply the selected wallpaper
hyprctl hyprpaper reload ,"$WALLPAPER"
