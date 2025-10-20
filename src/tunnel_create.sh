#!/usr/bin/env bash
# --- Tunnel creation and config setup ---

create_tunnel() {
  local app_name="$1"
  local domain="$2"
  local port="$3"
  local full_hostname="${app_name}.${domain}"
  local tunnel_dir="$HOME/.cloudflared"
  local config_dir="$tunnel_dir/configs"
  local config_file="$config_dir/${app_name}.yml"

  log "Creating tunnel for app: $app_name (${full_hostname})"

  # Ensure config directory exists
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
    log "📁 Created config directory: $config_dir"
  fi

  # Check if tunnel already exists
  if cloudflared tunnel list 2>/dev/null | grep -qw "$app_name"; then
    log "ℹ️ Tunnel '$app_name' already exists."
  else
    cloudflared tunnel create "$app_name"
    log "✅ Tunnel '$app_name' created successfully."
  fi

  # Get tunnel ID safely (column 1 = ID, column 2 = NAME)
  local tunnel_id
  tunnel_id=$(cloudflared tunnel list 2>/dev/null | awk -v name="$app_name" '$2 == name {print $1; exit}')

  if [[ -z "$tunnel_id" ]]; then
    log "❌ Failed to retrieve tunnel ID for $app_name."
    exit 1
  fi

  # Generate config
  log "🛠️ Writing config file: $config_file"
  cat > "$config_file" <<EOF
tunnel: ${tunnel_id}
credentials-file: ${tunnel_dir}/${tunnel_id}.json

ingress:
  - hostname: ${full_hostname}
    service: http://localhost:${port}
    originRequest:
      noTLSVerify: true
      connectTimeout: 600s
  - service: http_status:404

origincert: ${tunnel_dir}/cert.pem
protocol: http2
EOF

  log "✅ Config written with timeout 600s"

  # Start tunnel
  log "🚀 Starting tunnel '${app_name}'..."
  cloudflared tunnel --config "$config_file" run "$tunnel_id"
}
