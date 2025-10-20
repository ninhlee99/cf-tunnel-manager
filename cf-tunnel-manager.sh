#!/usr/bin/env bash
# --- Cloudflare Tunnel Manager CLI (entrypoint) ---
# Requires src/ util.sh, check_env.sh, tunnel_create.sh, dns_route.sh, tunnel_manage.sh

set -e
BASE_DIR="$HOME/.cf-tunnel-manager"
# BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# load src
if [ -f "$BASE_DIR/src/util.sh" ]; then
  source "$BASE_DIR/src/util.sh"
else
  echo "[ERROR] Missing src/util.sh" >&2
  exit 1
fi

if [ -f "$BASE_DIR/src/check_env.sh" ]; then
  source "$BASE_DIR/src/check_env.sh"
else
  error "Missing src/check_env.sh"
  exit 1
fi

if [ -f "$BASE_DIR/src/tunnel_create.sh" ]; then
  source "$BASE_DIR/src/tunnel_create.sh"
else
  error "Missing src/tunnel_create.sh"
  exit 1
fi

if [ -f "$BASE_DIR/src/dns_route.sh" ]; then
  source "$BASE_DIR/src/dns_route.sh"
else
  error "Missing src/dns_route.sh"
  exit 1
fi

if [ -f "$BASE_DIR/src/tunnel_remove.sh" ]; then
  source "$BASE_DIR/src/tunnel_remove.sh"
else
  error "Missing src/tunnel_remove.sh"
  exit 1
fi

if [ -f "$BASE_DIR/src/tunnel_manage.sh" ]; then
  source "$BASE_DIR/src/tunnel_manage.sh"
else
  error "Missing src/tunnel_manage.sh"
  exit 1
fi

# Helper: check args
require_args() {
  if [ $# -lt 1 ]; then
    error "Missing arguments"
    exit 1
  fi
}

# Command dispatch
case "${1:-}" in
  create)
    domain="$2"; app="$3"; port="$4"
    if [[ -z "$domain" || -z "$app" || -z "$port" ]]; then
      error "Usage: cf-tunnel-manager create <domain> <app_name> <port>"
      exit 1
    fi
    log "Ensure cloudflared installed..."
    check_requirements
    log "Ensure logged in..."
    check_login   # will run login flow if not logged
    create_tunnel "$app" "$domain" "$port"
    add_dns_route "$app" "$domain"
    log "${app}.${domain}"
    ;;


  list)
    list_tunnels
    ;;

  run)
    shift || true
    if [ -z "${1:-}" ]; then
      error "Usage: cf-tunnel-manager run <app_name>"
      exit 1
    fi
    start_tunnel "$1"
    ;;

  start)
    interactive_start
    ;;

  install)
    log "Installing cloudflared on this machine..."
    install_cloudflared
    log "cloudflared should now be installed at: $(command -v cloudflared || echo '(not found)')"
    ;;

  login)
    # If already have cert.pem treat as logged in
    if [[ -f "$HOME/.cloudflared/cert.pem" ]]; then
      log "✅ Already logged in to Cloudflare (found $HOME/.cloudflared/cert.pem)"
      # print account info (best-effort)
      set +e
      cloudflared tunnel list >/dev/null 2>&1 && log "cloudflared can list tunnels (login valid)"
      set -e
      exit 0
    fi

    log "Opening browser to perform 'cloudflared tunnel login'... complete the auth in your browser."
    cloudflared tunnel login

    if [[ -f "$HOME/.cloudflared/cert.pem" ]]; then
      log "🎉 Login successful! cert.pem found at $HOME/.cloudflared/cert.pem"
    else
      error "Login did not complete or cert.pem not found. Re-run 'cf-tunnel-manager login' to try again."
      exit 1
    fi
    ;;

  remove)
    app="$2"
    remove_tunnel "$app"
    ;;


  help|-h|--help|'')
    cat <<EOF
cf-tunnel-manager - Manage Cloudflare Tunnels (modular)

Usage:
  cf-tunnel-manager create <domain> <app_name> <port> Create tunnel, write config, add DNS route
  cf-tunnel-manager remove <app_name>                 Remove a tunnel and its credentials
  cf-tunnel-manager list                              List all tunnels
  cf-tunnel-manager run <app_name>                    Start tunnel (foreground)
  cf-tunnel-manager start                             Choose & start tunnel interactively

  # New utilities
  cf-tunnel-manager install                           Install cloudflared on this machine (apt/dnf/brew)
  cf-tunnel-manager login                             Run 'cloudflared tunnel login' (opens browser). If already logged, reports success.

  cf-tunnel-manager help                              Show this help

Notes:
 - Ensure you run commands with a user that can sudo for operations that write /etc or install packages.
 - 'create' will call check_login which triggers login flow if not already authenticated.
EOF
    ;;

  *)
    error "Unknown command: $1"
    echo "Run 'cf-tunnel-manager help' for usage."
    exit 1
    ;;
esac
