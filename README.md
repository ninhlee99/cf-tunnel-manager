# 🌩️ cf-tunnel-manager

**cf-tunnel-manager** là công cụ CLI giúp bạn **tạo, quản lý và khởi chạy Cloudflare Tunnel** một cách tự động và thân thiện — chỉ với vài dòng lệnh.
Công cụ này giúp bạn public ứng dụng nội bộ ra Internet mà **không cần mở port, không cần IP tĩnh**, và tự động cấu hình DNS, timeout, TLS...

## 🚀 Tính năng chính
✅ Tạo Cloudflare Tunnel tự động
✅ Cấu hình `config.yml` tự động (multi-app, timeout 600s, noTLSVerify)
✅ Tự động add/remove DNS route theo domain
✅ Tự động cài đặt và đăng nhập Cloudflare (`cloudflared`)
✅ Hỗ trợ alias: `ctm` hoặc `cf-tunnel`
✅ Quản lý tunnel: list, run, start, remove
✅ Hoạt động trên Linux & macOS

## ⚙️ Cài đặt
Clone project về:
```bash
$  git  clone  https://github.com/ninhlee99/cf-tunnel-manager.git  ~/.cf-tunnel-manager
$  cd  ~/.cf-tunnel-manager
$  ./install.sh
```
Bạn sẽ thấy:
```
[INFO] Installing cf-tunnel-manager to /usr/local/bin...
Create alias 'ctm' and 'cf-tunnel'? [Y/n]: Y
[INFO] Aliases added: ctm, cf-tunnel ✅
[INFO] Installation complete ✅
Try running: ctm list
```
🔥 Sau khi cài đặt xong, bạn có thể dùng ctm hoặc cf-tunnel thay cho cf-tunnel-manager.

## 🧠 Cách sử dụng
### 🔑 Đăng nhập Cloudflare
Trước tiên, hãy đăng nhập Cloudflare để CLI có thể tạo tunnel:
```bash
$  ctm  login
```
Sau khi đăng nhập, CLI sẽ lưu ~/.cloudflared/cert.pem và xác nhận:
> 🎉 Login successful! cert.pem found at ~/.cloudflared/cert.pem

### 🌍 Tạo tunnel mới

```bash
$  ctm  create  <domain>  <app_name>  <port>
```
> Ex: ctm  create  tel-annas.io.vn  n8n  5678

CLI sẽ:
- Kiểm tra cloudflared có sẵn hay chưa — nếu chưa sẽ tự cài.
- Kiểm tra login — nếu chưa sẽ mở trình duyệt đăng nhập.
- Tạo tunnel n8n
- Viết config file ~/.cloudflared/configs/n8n.yml
- Thêm DNS route: n8n.tel-annas.io.vn
- Tự động chạy tunnel foreground

### 📜 Liệt kê danh sách tunnel
```bash
$  ctm  list
```
```markdown

STT  APP NAME    TUNNEL ID
-----------------------------------------------
1.   daijob-api  c6089f10-3c9b-44a0-bbc6-0fd5c703712b
2.   n8n         2904b958-bac2-48a3-9e8d-53165d845f6a
```
### ▶️ Run tunnel theo tên app
```bash
$  ctm  run  <app_name>
```
Hoặc chọn từ danh sách:
```bash
$  ctm  start
> Vị trí tunnel muốn run (Ex:  1)
```
### ❌ Xoá tunnel
```bash
$  ctm  remove  <app_name>
```
or
```bash
$  ctm  remove
> Vị trí tunnel muốn xoá (Ex:  1)
```
CLI sẽ:
- Xoá tunnel và file credentials tương ứng
- Nếu không truyền app name → sẽ hiện list tunnel để chọn

### 🛠️ Cài đặt cloudflared thủ công
Nếu bạn chỉ muốn cài cloudflared mà không tạo tunnel:
```bash
$  ctm  install
```

### 🧩 Cấu hình được tạo mẫu
Ví dụ file ~/.cloudflared/configs/n8n.yml:
```yaml
tunnel: c6089f10-3c9b-44a0-bbc6-0fd5c703712b
credentials-file: /Users/you/.cloudflared/c6089f10-3c9b-44a0-bbc6-0fd5c703712b.json
ingress:
- hostname: n8n.tel-annas.io.vn
service: https://localhost:5678
originRequest:
noTLSVerify: true
connectTimeout: 600s
- service: http_status:404
origincert: /Users/you/.cloudflared/cert.pem
protocol: http2
```

### 🧹 Gỡ cài đặt
Xoá CLI và alias:
```bash
sudo  rm  /usr/local/bin/cf-tunnel-manager
```
[bashrc]
```bash
sed  -i  '/alias ctm=/d'  ~/.bashrc
sed  -i  '/alias cf-tunnel=/d'  ~/.bashrc
```
[zshrc]
```bash
sed  -i  '/alias ctm=/d'  ~/.zshrc
sed  -i  '/alias cf-tunnel=/d'  ~/.zshrc
```
