#!/usr/bin/env bash
# --- DNS route configuration ---

add_dns_route() {
  local app_name="$1"
  local domain="$2"
  local overwrite="$3"

  local hostname="${app_name}.${domain}"
  log "🔍 Checking DNS route for ${hostname}..."

  # Lấy tunnel ID
  local tunnel_id
  tunnel_id=$(cloudflared tunnel list | grep -w "$app_name" | awk '{print $1}' | head -n1 || true)
  if [[ -z "$tunnel_id" ]]; then
    error "❌ Tunnel $app_name not found. Please create it first."
    exit 1
  fi

  # Kiểm tra xem DNS record đã tồn tại chưa
  local existing_record
  existing_record=$(cloudflared tunnel route dns list 2>/dev/null | grep -w "$hostname" | awk '{print $2}' | head -n1 || true)

  if [[ -n "$existing_record" ]]; then
    if [[ "$overwrite" == "true" ]]; then
      log "⚠️ DNS record already exists — overwriting with --overwrite-dns flag..."
      cloudflared tunnel route dns --overwrite-dns "$tunnel_id" "$hostname"
      log "✅ DNS route for ${hostname} overwritten successfully."
    else
      log "⚠️ DNS record already exists for ${hostname}. Skipping creation (use --force to overwrite)."
    fi
  else
    log "🌐 Adding DNS route ${hostname} → tunnel ${tunnel_id}..."
    cloudflared tunnel route dns "$tunnel_id" "$hostname"
    log "✅ DNS route added for ${hostname}."
  fi
}
