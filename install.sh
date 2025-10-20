#!/usr/bin/env bash
set -e

CLI_NAME="cf-tunnel-manager"
TARGET="/usr/local/bin"
SOURCE_DIR="$HOME/.cf-tunnel-manager"

echo "[INFO] Installing $CLI_NAME..."

# Kiểm tra xem source đã tồn tại chưa
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "[ERROR] Folder $SOURCE_DIR not found."
  echo "👉 Hãy clone repo về bằng lệnh:"
  echo "   git clone https://github.com/yourname/cf-tunnel-manager.git ~/.cf-tunnel-manager"
  exit 1
fi

# Copy file chính
sudo cp "$SOURCE_DIR/$CLI_NAME.sh" "$TARGET/$CLI_NAME"
sudo chmod +x "$TARGET/$CLI_NAME"

# Tạo alias
read -rp "Create alias 'ctm' and 'cf-tunnel'? [Y/n]: " choice
if [[ "$choice" =~ ^[Yy]?$ ]]; then
  SHELL_RC="$HOME/.bashrc"
  if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
  fi

  {
    echo "alias ctm='$CLI_NAME'"
    echo "alias cf-tunnel='$CLI_NAME'"
  } >> "$SHELL_RC"

  echo "[INFO] Aliases added to $SHELL_RC ✅"
  echo "[INFO] Run 'source $SHELL_RC' or restart terminal."
  source "$SHELL_RC"
fi

echo "[INFO] Installation complete ✅"
echo "Try running: ctm list"
