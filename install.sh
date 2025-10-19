#!/usr/bin/env bash
# --- Installer for cf-tunnel-manager ---

set -e
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/usr/local/bin"
CLI_NAME="cf-tunnel-manager"

echo "[INFO] Installing $CLI_NAME to $TARGET..."
sudo cp "$BASE_DIR/$CLI_NAME.sh" "$TARGET/$CLI_NAME"
sudo chmod +x "$TARGET/$CLI_NAME"

# Ask for alias
read -rp "Create alias 'ctm' and 'cf-tunnel'? [Y/n]: " choice
if [[ "$choice" =~ ^[Yy]?$ ]]; then
  {
    echo "alias ctm='$CLI_NAME'"
    echo "alias cf-tunnel='$CLI_NAME'"
  } >> "$HOME/.bashrc"
  source "$HOME/.bashrc"
  echo "[INFO] Aliases added: ctm, cf-tunnel ✅"
fi

echo "[INFO] Installation complete ✅"
echo "Try running: ctm list"
