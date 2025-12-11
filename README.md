<!-- omit from toc -->
# Omarchy Tailscale

A sleek tool for managing Tailscale account switching with an interactive menu, Waybar integration, and Hyprland keybindings.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/andrepadez/omarchy-tailscale/master/install.sh | bash
```

**Or preview first with `--dry-run`:**

```bash
curl -fsSL https://raw.githubusercontent.com/andrepadez/omarchy-tailscale/master/install.sh | bash -- --dry-run
```

## Table of Contents

- [Features](#features)
- [Usage](#usage)
  - [Interactive Menu](#interactive-menu)
  - [Status (Waybar)](#status-waybar)
  - [Quick Toggle](#quick-toggle)
  - [Setup Instructions](#setup-instructions)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Waybar](#waybar)
  - [Hyprland](#hyprland)
- [Requirements](#requirements)
- [License](#license)

## Features

🔄 **Interactive Menu** - Fuzzy-searchable account selection with visual indicators

🔗 **Account Management** - Switch between multiple Tailscale accounts seamlessly

📊 **Waybar Integration** - Real-time connection status in your taskbar

⌨️ **Keybinding Support** - Launch the menu with a keyboard shortcut in Hyprland

🔌 **Connection Control** - Start/stop Tailscale from the menu

🎨 **Visual Polish** - Clean UI with status indicators

## Installation

### Automatic Installation

```bash
curl -fsSL https://raw.githubusercontent.com/andrepadez/omarchy-tailscale/master/install.sh | bash
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/andrepadez/omarchy-tailscale
cd omarchy-tailscale
```

2. Copy the script to your local bin:

```bash
cp omarchy-tailscale.sh ~/.local/bin/
chmod +x ~/.local/bin/omarchy-tailscale.sh
```

3. Create a symlink (optional):

```bash
mkdir -p ~/.local/share/omarchy/bin
ln -s ~/.local/bin/omarchy-tailscale.sh ~/.local/share/omarchy/bin/omarchy-tailscale
```

## Usage

### Interactive Menu

Launch the interactive account selector:

```bash
omarchy-tailscale
```

Features:

- 🔗 Current account shown with indicator
- 🖥️ Other available accounts listed
- Auto-switch to selected account
- Start/stop Tailscale directly from menu

### Status (Waybar)

Get JSON status output for Waybar integration:

```bash
omarchy-tailscale status
```

Output example:

```json
{"text":"pastilhas","percentage":100,"class":"connected","icon":"🔗"}
```

### Quick Toggle

Quickly cycle to the next account:

```bash
omarchy-tailscale switch
```

### Setup Instructions

View setup instructions for Waybar and Hyprland:

```bash
omarchy-tailscale setup
```

## Configuration

### Waybar

Add this module to your Waybar configuration (`~/.config/waybar/config`):

```json
"custom/tailscale": {
  "format": "{icon} {text}",
  "return-type": "json",
  "interval": 2,
  "format-icons": [
    "🌐",
    "🔗"
  ],
  "tooltip": false,
  "exec": "omarchy-tailscale status",
  "on-click": "omarchy-tailscale"
}
```

Then add `"custom/tailscale"` to your bar modules list:

```json
"modules-right": ["custom/tailscale", ...]
```

#### Styling

Optional CSS to customize appearance in `~/.config/waybar/style.css`:

```css
#custom-tailscale {
  color: #8be9fd;
  margin: 0 10px;
}

#custom-tailscale.connected {
  color: #50fa7b;
}

#custom-tailscale.disconnected {
  color: #ff79c6;
}
```

### Hyprland

Add this keybinding to your Hyprland config (`~/.config/hypr/hyprland.conf`):

```conf
bind = SUPER SHIFT, T, exec, omarchy-tailscale
```

## Requirements

- **tailscale** - Tailscale CLI client
- **walker** - Fuzzy finder for menu
- **jq** - JSON processor
- **sudo** - For account switching (Tailscale operations)

### Installation

**Arch Linux / Manjaro:**

```bash
sudo pacman -S tailscale walker jq
```

**Fedora:**

```bash
sudo dnf install tailscale walker jq
```

**Ubuntu / Debian:**

```bash
sudo apt install jq
# Install tailscale and walker from their respective sources
```

## Troubleshooting

### Script not found in PATH

Make sure `~/.local/bin` is in your `$PATH`:

```bash
echo $PATH | grep ~/.local/bin
```

If not, add to your shell config (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Walker menu not showing

Ensure you're using a compatible terminal. Recommended:

- WezTerm
- Alacritty
- Ghostty
- Kitty

### Sudo password required

Tailscale operations require sudo. Make sure your user has the necessary permissions for Tailscale commands.

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Made with ❤️ for Tailscale users**
