#!/usr/bin/env bash

# Detect which fuzzy finder is available
if command -v walker &> /dev/null; then
  FUZZY_FINDER="walker"
elif command -v fuzzel &> /dev/null; then
  FUZZY_FINDER="fuzzel"
else
  echo "Error: Neither walker nor fuzzel found in PATH"
  exit 1
fi

# Function to call fuzzy finder with appropriate arguments
run_fuzzy() {
  if [[ "$FUZZY_FINDER" == "walker" ]]; then
    walker -d --placeholder "$1"
  else
    # fuzzel - don't pass placeholder to avoid display issues
    fuzzel -d
  fi
}

# --- Handle "status" arg ---
if [[ "$1" == "status" ]]; then
  if ! tailscale status &>/dev/null; then
    echo '{"text":"OFF","percentage":0,"class":"disconnected","icon":"🌐"}'
    exit 0
  fi

  account=$(sudo tailscale switch --list | awk '/\*/ {print $3}' | sed 's/\*$//')

  if [ -n "$account" ]; then
    echo "{\"text\":\"$account\",\"percentage\":100,\"class\":\"connected\",\"icon\":\"🔗\"}"
  else
    echo '{"text":"ON","percentage":100,"class":"connected","icon":"🔗"}'
  fi
  exit 0
fi

# --- Handle "switch" arg ---
if [[ "$1" == "switch" ]]; then
  # Toggle between accounts (same as original)
  accounts=($(sudo tailscale switch --list | awk 'NR>1 {print $3}'))
  current=$(sudo tailscale switch --list | awk '/\*/ {print $3}' | sed 's/\*$//')

  # find current index
  for i in "${!accounts[@]}"; do
    if [[ "${accounts[$i]%\*}" == "$current" ]]; then
      current_index=$i
      break
    fi
  done

  # compute next index (wrap around with modulo)
  next_index=$(((current_index + 1) % ${#accounts[@]}))
  next_account="${accounts[$next_index]%\*}"

  # switch to next account
  sudo tailscale switch "$next_account"
  exit $?
fi

# --- Handle "setup" arg ---
if [[ "$1" == "setup" ]]; then
  echo ""
  echo "=== Waybar Configuration ==="
  echo ""
  echo "Add this to your waybar config (~/.config/waybar/config):"
  echo ""
  echo '  "custom/tailscale": {'
  echo '    "format": "{icon} {text}",'
  echo '    "return-type": "json",'
  echo '    "interval": 2,'
  echo '    "format-icons": ['
  echo '      "🌐",'
  echo '      "🔗"'
  echo '    ],'
  echo '    "tooltip": false,'
  echo '    "exec": "omarchy-tailscale status",'
  echo '    "on-click": "omarchy-tailscale"'
  echo '  },'
  echo ""
  echo "Then add \"custom/tailscale\" to your waybar bar module."
  echo ""
  echo "=== Hyprland Keybinding ==="
  echo ""
  echo "Add this to your hyprland keybindings (~/.config/hypr/hyprland.conf):"
  echo ""
  echo "  bind = SUPER SHIFT, T, exec, omarchy-tailscale"
  echo ""
  exit 0
fi

# --- Default (Fuzzy Finder Menu) ---
# Check if Tailscale is running
if ! tailscale status &>/dev/null; then
  action=$(echo -e "🔗 Start Tailscale\n❌ Exit" | run_fuzzy "Tailscale is Offline")
  case "$action" in
    "🔗 Start Tailscale")
      sudo tailscale up
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
fi

# Get current account and available accounts
accounts_data=$(sudo tailscale switch --list | tail -n +2)  # Skip header

# Parse accounts into arrays
declare -A ACCOUNT_MAP  # Maps display name to account name
declare -a DISPLAY_NAMES
current_account_found=""

while IFS= read -r line; do
  # Skip empty lines and header
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^ID ]] && continue
  
  # Parse: ID, Tailnet, Account (with optional *)
  id=$(echo "$line" | awk '{print $1}')
  account=$(echo "$line" | awk '{print $NF}' | sed 's/\*$//')
  display_name="$id - $account"
  
  ACCOUNT_MAP["$display_name"]="$account"
  DISPLAY_NAMES+=("$display_name")
  
  if [[ "$line" =~ \*$ ]]; then
    current_account_found="$display_name"
  fi
done <<<"$accounts_data"

# -------- Fuzzy Finder Menu --------

show_menu() {
  {
    # Show current account first
    if [ -n "$current_account_found" ]; then
      echo "🔗 $current_account_found"
    fi
    
    # Show other accounts
    for display_name in "${DISPLAY_NAMES[@]}"; do
      if [ "$display_name" != "$current_account_found" ]; then
        echo "$display_name"
      fi
    done
    
    # Show disconnect option only if connected
    if [ -n "$current_account_found" ]; then
      echo "🔌 Disconnect"
    fi
    
    echo "❌ Exit"
  } | run_fuzzy "Select Tailscale Account"
}

# -------- Menu Flow --------

selected="$(show_menu)"
[ -z "$selected" ] && exit

# Remove icon prefix if present (only emoji followed by space)
selected_clean=$(echo "$selected" | sed 's/^[🔗🔌❌] //')

case "$selected_clean" in
  "Disconnect")
    sudo tailscale down
    ;;
  "Exit")
    exit 0
    ;;
  *)
    # Check if it's an account in the map
    account_to_switch="${ACCOUNT_MAP[$selected_clean]}"
    if [[ -n "$account_to_switch" ]]; then
      sudo tailscale switch "$account_to_switch"
    fi
    ;;
esac