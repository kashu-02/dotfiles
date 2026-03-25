#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${HOME}/.wallpapers"
WALL_LOC="${WALLPAPER_DIR}/current_wallpaper"

if [[ ! -d "${WALLPAPER_DIR}" ]]; then
  exit 0
fi

mapfile -t WALLPAPERS < <(
  find "${WALLPAPER_DIR}" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \)
)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
  exit 0
fi

CURRENT=""
if [[ -e "${WALL_LOC}" ]]; then
  CURRENT="$(readlink -f "${WALL_LOC}" || true)"
fi

if [[ ${#WALLPAPERS[@]} -eq 1 ]]; then
  WALLPAPER="${WALLPAPERS[0]}"
else
  while :; do
    WALLPAPER="$(printf '%s\n' "${WALLPAPERS[@]}" | shuf -n 1)"
    [[ -n "${CURRENT}" && "${WALLPAPER}" == "${CURRENT}" ]] || break
  done
fi

ln -sfn "${WALLPAPER}" "${WALL_LOC}"
hyprctl hyprpaper wallpaper ', "'"${WALLPAPER}"'"'
