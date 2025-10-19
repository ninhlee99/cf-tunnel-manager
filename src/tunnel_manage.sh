#!/usr/bin/env bash
# --- Tunnel management (list, start, interactive start) ---

list_tunnels() {
  log "🌐 Danh sách Cloudflare Tunnels:"

  # Bỏ dòng tiêu đề, chỉ lấy dòng có tên và ID thật
  local tunnels
  tunnels=$(cloudflared tunnel list 2>/dev/null | awk 'NR>1 && $2 != "NAME" {count+=1; printf "%-3s %-25s %s\n", count".", $2, $1}')

  if [[ -z "$tunnels" ]]; then
    echo "⚠️  Không có tunnel nào được tạo."
    exit 0
  fi

  echo ""
  echo "STT  APP NAME                 TUNNEL ID"
  echo "-----------------------------------------------"
  echo "$tunnels"
  echo ""
}


start_tunnel() {
  local app_name="$1"
  local tunnel_id
  local config_file="$HOME/.cloudflared/config/${app_name}.yml"
  tunnel_id=$(cloudflared tunnel list | grep "$app_name" | awk '{print $1}')
  [[ -z "$tunnel_id" ]] && { error "Tunnel '$app_name' not found."; exit 1; }

  log "Starting tunnel: $app_name ($tunnel_id)"
  cloudflared tunnel --config "$config_file" run "$tunnel_id"
}

interactive_start() {
  local tunnels
  tunnels=$(cloudflared tunnel list | tail -n +2 | nl)
  echo "$tunnels"
  read -rp "Enter tunnel number to start: " idx
  local app
  app=$(cloudflared tunnel list | tail -n +2 | awk "NR==$idx {print \$2}")
  [[ -z "$app" ]] && error "Invalid selection" && exit 1
  start_tunnel "$app"
}
