#!/bin/bash

CONFIG_FILE="$HOME/.config/start-launcher/tools.list"
mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"

echo -e "\e[1;36m== Add a new script to Start Launcher ==\e[0m"

read -rp "📝 Display name (e.g., 'Backup Tool'): " display
read -rp "📁 Full path to script (e.g., ~/scripts/backup.sh): " path

expanded_path=$(eval echo "$path")

if [[ ! -f "$expanded_path" ]]; then
  echo -e "\e[1;31m[ERROR]\e[0m Script not found at: $expanded_path"
  exit 1
fi

echo "$display=$expanded_path" >> "$CONFIG_FILE"
echo -e "\e[1;32m[SUCCESS]\e[0m Added '$display' to the launcher."

sleep 1

