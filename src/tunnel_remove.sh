#!/usr/bin/env bash
# --- Tunnel remove app name ---

remove_tunnel() {
  local app_name="$1"

  # 1. Lấy danh sách tunnel hiện có (Chỉnh sửa để chỉ lấy dữ liệu sạch)
  local tunnels
  # Lệnh awk đã được sửa để chỉ lấy TÊN và ID, sau khi bỏ qua dòng tiêu đề gốc
  tunnels=$(cloudflared tunnel list 2>/dev/null | awk 'NR>1 && $2 != "NAME" {count+=1; printf "%-3s %-25s %s\n", count".", $2, $1}')

  if [[ -z "$tunnels" ]]; then
    error "⚠️ Không có tunnel nào để xoá."
    exit 0
  fi

  # 2. Xử lý lựa chọn tunnel nếu không có tên được cung cấp
  if [[ -z "$app_name" ]]; then
    echo ""
    echo "STT  APP NAME                 TUNNEL ID"
    echo "-----------------------------------------------"

    # In ra danh sách đã được đánh số STT
    echo "$tunnels" # | nl -w3 -s".  " | awk '{printf "%-5s %-25s %s\n", $1, $2, $3}'

    echo ""
    read -p "🔢 Nhập số thứ tự tunnel muốn xoá: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
      error "❌ Lựa chọn không hợp lệ."
      exit 1
    fi

    # Lấy TÊN tunnel (field 2) dựa trên số thứ tự (choice)
    # Lệnh 'nl' đánh số thứ tự, sau đó 'awk' chọn dòng và lấy tên
    app_name=$(echo "$tunnels" | awk -v n="$choice" 'NR==n {print $2}')

    if [[ -z "$app_name" ]]; then
      error "❌ Không tìm thấy tunnel tương ứng với số $choice."
      exit 1
    fi
  fi

  # 3. Tìm Tunnel ID
  log "🧩 Đang kiểm tra tunnel '$app_name'..."
  local tunnel_id
  # $tunnels đã là dữ liệu sạch: TÊN ID. Chỉ cần tìm TÊN và lấy ID (trường $2)
  tunnel_id=$(echo "$tunnels" | awk -v name="$app_name" '$2 == name {print $3; exit}')
  if [[ -z "$tunnel_id" ]]; then
    error "❌ Không tìm thấy tunnel '$app_name' (ID không xác định)."
    exit 1
  fi

  log "Tunnel found: $app_name ($tunnel_id)"
  if ask_confirm "Are you sure you want to delete this tunnel and its credentials?"; then
    cloudflared tunnel delete "$app_name" || {
      error "Failed to delete tunnel."
      return 1
    }

    # Delete credential JSON if exists
    local cred_file="$HOME/.cloudflared/${tunnel_id}.json"
    if [[ -f "$cred_file" ]]; then
      rm -f "$cred_file"
      log "Deleted credentials file: $cred_file"
    fi

    local conf_file="$HOME/.cloudflared/configs/${app_name}.yml"
    if [[ -f "$conf_file" ]]; then
      rm -f "$conf_file"
      log "Deleted config file: $conf_file"
    fi

    log "✅ Tunnel '$app_name' removed successfully."
  else
    log "❎ Deletion cancelled."
  fi
}
