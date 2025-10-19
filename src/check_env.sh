#!/usr/bin/env bash
# --- Check and prepare environment ---

check_requirements() {
  if ! command -v cloudflared >/dev/null 2>&1; then
    warn "Cloudflared not found. Installing..."
    install_cloudflared
  else
    log "Cloudflared found ✅"
  fi
}

install_cloudflared() {
  local os=$(uname -s)
  case "$os" in
    Linux)
      curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg
      echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
      sudo apt update && sudo apt install -y cloudflared
      ;;
    Darwin)
      brew install cloudflared
      ;;
    *)
      error "Unsupported OS: $os"
      exit 1
      ;;
  esac
}

check_login() {
  if [[ -f "$HOME/.cloudflared/cert.pem" ]]; then
    log "✅ Cloudflare login detected"
  else
    warn "No login found — running cloudflared login..."
    cloudflared tunnel login
    [[ -f "$HOME/.cloudflared/cert.pem" ]] && log "🎉 Login successful!" || { error "Login failed"; exit 1; }
  fi
}
