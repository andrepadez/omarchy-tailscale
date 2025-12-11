#!/usr/bin/env bash

set -e

# Parse flags
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/andrepadez/omarchy-tailscale"
INSTALL_DIR="${HOME}/.local/bin"
MAIN_SCRIPT="omarchy-tailscale.sh"

# Helper functions
print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check dependencies
check_dependencies() {
  print_info "Checking dependencies..."
  
  local missing=()
  local fuzzy_finder=""
  
  # Check for required dependencies
  for cmd in tailscale jq; do
    if ! command -v "$cmd" &> /dev/null; then
      missing+=("$cmd")
    fi
  done
  
  # Check for fuzzy finder (walker or fuzzel)
  if command -v walker &> /dev/null; then
    fuzzy_finder="walker"
  elif command -v fuzzel &> /dev/null; then
    fuzzy_finder="fuzzel"
  else
    missing+=("walker or fuzzel")
  fi
  
  if [ ${#missing[@]} -ne 0 ]; then
    print_error "Missing required dependencies: ${missing[*]}"
    print_info "Please install the following before continuing:"
    for cmd in "${missing[@]}"; do
      echo "  - $cmd"
    done
    exit 1
  fi
  
  print_success "All dependencies found"
  [ -n "$fuzzy_finder" ] && print_info "Using fuzzy finder: $fuzzy_finder"
}

# Create installation directory
setup_directory() {
  print_info "Setting up installation directory..."
  
  if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    print_success "Created directory: $INSTALL_DIR"
  fi
}

# Create symlink in share directory
create_share_symlink() {
  local share_bin_dir="${HOME}/.local/share/omarchy/bin"
  local symlink_path="${share_bin_dir}/omarchy-tailscale"
  
  print_info "Creating symlink in $share_bin_dir..."
  
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY-RUN] Would create directory: $share_bin_dir"
    print_info "[DRY-RUN] Would create symlink: $symlink_path -> ${INSTALL_DIR}/${MAIN_SCRIPT}"
  else
    if [ ! -d "$share_bin_dir" ]; then
      mkdir -p "$share_bin_dir"
    fi
    
    if [ -L "$symlink_path" ] || [ -f "$symlink_path" ]; then
      rm "$symlink_path"
    fi
    
    ln -s "${INSTALL_DIR}/${MAIN_SCRIPT}" "$symlink_path"
  fi
  
  print_success "Created symlink: $symlink_path"
}

# Download script from GitHub
download_script() {
  local script_name="$1"
  local script_url="${REPO_URL}/raw/master/${script_name}"
  local script_path="${INSTALL_DIR}/${script_name}"
  
  print_info "Downloading $script_name..."
  
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY-RUN] Would download from: $script_url"
    print_info "[DRY-RUN] Would install to: $script_path"
    print_info "[DRY-RUN] Would make executable"
  else
    if ! curl -fsSL "$script_url" -o "$script_path"; then
      print_error "Failed to download $script_name"
      exit 1
    fi
    
    chmod +x "$script_path"
  fi
  
  print_success "Installed $script_name"
}



# Main installation flow
main() {
  clear
  echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}║  ${YELLOW}Omarchy Tailscale Installer (DRY-RUN)${BLUE}  ║${NC}"
  else
    echo -e "${BLUE}║  ${YELLOW}Omarchy Tailscale Installer${BLUE}       ║${NC}"
  fi
  echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
  echo ""
  
  check_dependencies
  setup_directory
  
  print_info "Downloading script..."
  download_script "$MAIN_SCRIPT"
  
  create_share_symlink
  
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  Installation completed successfully! ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
  echo ""
  print_success "You can now run: ${YELLOW}omarchy-tailscale${NC}"
  print_info "Script installed to: $INSTALL_DIR"
  echo ""
  print_info "Usage:"
  echo "  omarchy-tailscale          # Launch interactive menu"
  echo "  omarchy-tailscale status   # Show JSON status (for Waybar)"
  echo "  omarchy-tailscale switch   # Quick account toggle"
  echo ""
  echo ""
  print_info "Setup instructions:"
  echo ""
  "${INSTALL_DIR}/${MAIN_SCRIPT}" setup
}

# Run installation
main "$@"
