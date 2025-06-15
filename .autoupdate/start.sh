#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.local/bin/tools.list"
mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

choose_tool() {
  declare -A tools
  user_scripts=()
  for line in $(<"$CONFIG_FILE"); do
    IFS='=' read -r name path <<< "$line"
    [[ -n "$name" && -n "$path" ]] && tools["$name"]="$path" && user_scripts+=("$name")
  done

  # Menu structure
  menu_items=()
  for script in "${user_scripts[@]}"; do
    menu_items+=("📝 $script")
  done
  menu_items+=("➕ Add new script")
  menu_items+=("❌ Exit")

  # Show menu using fzf > gum > dialog > fallback
  if has_cmd fzf; then
    selected=$(printf "%s\n" "${menu_items[@]}" | \
      fzf --prompt="🎬 Select script > " --height=15 --reverse --pointer='▶' --border)
  elif has_cmd gum; then
    selected=$(gum choose --header="Select a script to run" "${menu_items[@]}")
  elif has_cmd dialog; then
    dialog_items=()
    for item in "${menu_items[@]}"; do
      dialog_items+=("$item" "")
    done
    selected=$(dialog --clear --title "Script Launcher" \
      --menu "Choose a script to run:" 20 60 12 "${dialog_items[@]}" 3>&1 1>&2 2>&3)
    clear
  else
    echo "Select a script:"
    select opt in "${menu_items[@]}"; do
      selected="$opt"
      break
    done
  fi

  echo "$selected"
}

# MAIN LOOP
while true; do
  choice=$(choose_tool)

  case "$choice" in
    "➕ Add new script")
      "$SCRIPT_DIR/addscript"
      continue
      ;;
    "❌ Exit"|"")
      echo "Goodbye!"
      exit 0
      ;;
    📝*)
      script_name="${choice#📝 }"
      script_path=""
      while IFS='=' read -r name path; do
        [[ "$name" == "$script_name" ]] && script_path="$path" && break
      done < "$CONFIG_FILE"

      if [[ -x "$script_path" ]]; then
        echo -e "\e[1;34m[INFO]\e[0m Running: $script_name"
        echo "-----------------------------"
        echo
        bash "$script_path"
        echo
        echo "-----------------------------"
        read -rp $'\e[1;33m[INFO]\e[0m Press Enter to return to menu...'
      else
        echo -e "\e[1;31m[ERROR]\e[0m Cannot execute: $script_path"
        read -rp "Press Enter to return to menu..."
      fi
      ;;
    *)
      echo -e "\e[1;33m[WARN]\e[0m Unknown option: $choice"
      ;;
  esac
done

