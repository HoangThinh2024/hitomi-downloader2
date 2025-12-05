# 🐳 Docker Deployment Guide / Hướng dẫn Triển khai Docker

[English](#english) | [Tiếng Việt](#tiếng-việt)

---

## English

### Overview

This guide explains how to run Hitomi Downloader as a web-accessible application using Docker. The application runs in a container with a virtual desktop that you can access through your web browser using noVNC.

### Architecture

- **Application**: Hitomi Downloader (Tauri desktop app)
- **Virtual Display**: Xvfb (X Virtual Frame Buffer)
- **Window Manager**: Fluxbox (lightweight)
- **VNC Server**: x11vnc
- **Web Interface**: noVNC (browser-based VNC client)
- **Process Manager**: Supervisor

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.0+ (optional, but recommended)
- At least 4GB RAM
- At least 10GB disk space

### Quick Start

#### Method 1: Using Docker Compose (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/HoangThinh2024/hitomi-downloader2.git
   cd hitomi-downloader2
   ```

2. **Start the container**:
   ```bash
   docker-compose up -d
   ```

3. **Access the application**:
   - Open your browser and go to: `http://localhost:6080`
   - The default VNC password is: `hitomi123`

4. **View logs**:
   ```bash
   docker-compose logs -f
   ```

5. **Stop the container**:
   ```bash
   docker-compose down
   ```

#### Method 2: Using Docker CLI

1. **Build the image**:
   ```bash
   docker build -t hitomi-downloader:local .
   ```

2. **Run the container**:
   ```bash
   docker run -d \
     --name hitomi-downloader \
     -p 6080:6080 \
     -p 5901:5901 \
     -v $(pwd)/downloads:/home/appuser/Downloads \
     -v hitomi-data:/home/appuser/.local/share/hitomi-downloader \
     hitomi-downloader:local
   ```

3. **Access the application**:
   - Web interface: `http://localhost:6080`
   - VNC client: `localhost:5901` (password: `hitomi123`)

### Using Pre-built Images from GitHub Container Registry

You can use pre-built images instead of building locally:

```bash
# Pull the latest image
docker pull ghcr.io/hoangthinh2024/hitomi-downloader2:latest

# Run the container
docker run -d \
  --name hitomi-downloader \
  -p 6080:6080 \
  -v $(pwd)/downloads:/home/appuser/Downloads \
  ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

### Configuration

#### Environment Variables

You can customize the container behavior with these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DISPLAY` | `:1` | X display number |
| `VNC_PORT` | `5901` | VNC server port |
| `NOVNC_PORT` | `6080` | noVNC web interface port |
| `TZ` | `Asia/Ho_Chi_Minh` | Timezone |

Example with custom settings:

```bash
docker run -d \
  --name hitomi-downloader \
  -p 8080:6080 \
  -e TZ=America/New_York \
  -v $(pwd)/downloads:/home/appuser/Downloads \
  ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

#### Volumes

Two volumes are recommended for persistent data:

1. **Application data**: `/home/appuser/.local/share/hitomi-downloader`
   - Stores settings, configuration, and cache
   
2. **Downloads**: `/home/appuser/Downloads`
   - Stores downloaded files

### Advanced Usage

#### Change VNC Password

1. Enter the running container:
   ```bash
   docker exec -it hitomi-downloader bash
   ```

2. Set new password:
   ```bash
   x11vnc -storepasswd your_new_password /home/appuser/.vnc/passwd
   ```

3. Restart the container:
   ```bash
   docker restart hitomi-downloader
   ```

#### Using with Reverse Proxy (Nginx)

Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name hitomi.yourdomain.com;

    location / {
        proxy_pass http://localhost:6080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Docker Compose with Additional Services

Example with Nginx reverse proxy:

```yaml
version: '3.8'

services:
  hitomi-downloader:
    image: ghcr.io/hoangthinh2024/hitomi-downloader2:latest
    volumes:
      - hitomi-data:/home/appuser/.local/share/hitomi-downloader
      - ./downloads:/home/appuser/Downloads
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - hitomi-downloader
    restart: unless-stopped

volumes:
  hitomi-data:
```

### Troubleshooting

#### Container won't start

Check logs:
```bash
docker logs hitomi-downloader
```

#### Can't access web interface

1. Verify container is running:
   ```bash
   docker ps | grep hitomi-downloader
   ```

2. Check port bindings:
   ```bash
   docker port hitomi-downloader
   ```

3. Test noVNC service:
   ```bash
   curl http://localhost:6080
   ```

#### Application crashes

View supervisor logs inside container:
```bash
docker exec hitomi-downloader cat /var/log/supervisor/supervisord.log
```

#### Low performance

Increase container resources:
```yaml
services:
  hitomi-downloader:
    # ... other settings ...
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

### Building Custom Images

If you want to modify the Dockerfile:

1. Edit `Dockerfile` with your changes
2. Build with a custom tag:
   ```bash
   docker build -t hitomi-downloader:custom .
   ```
3. Run your custom image:
   ```bash
   docker run -d -p 6080:6080 hitomi-downloader:custom
   ```

### Cleanup

Remove container and volumes:
```bash
# Stop and remove container
docker-compose down

# Remove volumes (WARNING: This deletes all data)
docker-compose down -v

# Remove image
docker rmi ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

---

## Tiếng Việt

### Tổng quan

Hướng dẫn này giải thích cách chạy Hitomi Downloader như một ứng dụng web sử dụng Docker. Ứng dụng chạy trong container với desktop ảo mà bạn có thể truy cập qua trình duyệt web sử dụng noVNC.

### Kiến trúc

- **Ứng dụng**: Hitomi Downloader (Tauri desktop app)
- **Màn hình ảo**: Xvfb (X Virtual Frame Buffer)
- **Trình quản lý cửa sổ**: Fluxbox (nhẹ)
- **VNC Server**: x11vnc
- **Giao diện Web**: noVNC (VNC client trên trình duyệt)
- **Quản lý tiến trình**: Supervisor

### Yêu cầu

- Docker Engine 20.10+
- Docker Compose v2.0+ (tùy chọn, nhưng khuyên dùng)
- Ít nhất 4GB RAM
- Ít nhất 10GB dung lượng đĩa

### Bắt đầu nhanh

#### Phương pháp 1: Sử dụng Docker Compose (Khuyên dùng)

1. **Clone repository**:
   ```bash
   git clone https://github.com/HoangThinh2024/hitomi-downloader2.git
   cd hitomi-downloader2
   ```

2. **Khởi động container**:
   ```bash
   docker-compose up -d
   ```

3. **Truy cập ứng dụng**:
   - Mở trình duyệt và truy cập: `http://localhost:6080`
   - Mật khẩu VNC mặc định: `hitomi123`

4. **Xem logs**:
   ```bash
   docker-compose logs -f
   ```

5. **Dừng container**:
   ```bash
   docker-compose down
   ```

#### Phương pháp 2: Sử dụng Docker CLI

1. **Build image**:
   ```bash
   docker build -t hitomi-downloader:local .
   ```

2. **Chạy container**:
   ```bash
   docker run -d \
     --name hitomi-downloader \
     -p 6080:6080 \
     -p 5901:5901 \
     -v $(pwd)/downloads:/home/appuser/Downloads \
     -v hitomi-data:/home/appuser/.local/share/hitomi-downloader \
     hitomi-downloader:local
   ```

3. **Truy cập ứng dụng**:
   - Giao diện web: `http://localhost:6080`
   - VNC client: `localhost:5901` (mật khẩu: `hitomi123`)

### Sử dụng Image có sẵn từ GitHub Container Registry

Bạn có thể sử dụng image đã build sẵn thay vì build local:

```bash
# Pull image mới nhất
docker pull ghcr.io/hoangthinh2024/hitomi-downloader2:latest

# Chạy container
docker run -d \
  --name hitomi-downloader \
  -p 6080:6080 \
  -v $(pwd)/downloads:/home/appuser/Downloads \
  ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

### Cấu hình

#### Biến môi trường

Bạn có thể tùy chỉnh container với các biến môi trường:

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `DISPLAY` | `:1` | Số hiệu X display |
| `VNC_PORT` | `5901` | Cổng VNC server |
| `NOVNC_PORT` | `6080` | Cổng giao diện web noVNC |
| `TZ` | `Asia/Ho_Chi_Minh` | Múi giờ |

Ví dụ với cài đặt tùy chỉnh:

```bash
docker run -d \
  --name hitomi-downloader \
  -p 8080:6080 \
  -e TZ=Asia/Ho_Chi_Minh \
  -v $(pwd)/downloads:/home/appuser/Downloads \
  ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

#### Volumes

Khuyên dùng hai volumes cho dữ liệu lâu dài:

1. **Dữ liệu ứng dụng**: `/home/appuser/.local/share/hitomi-downloader`
   - Lưu cài đặt, cấu hình và cache
   
2. **Downloads**: `/home/appuser/Downloads`
   - Lưu các file đã tải

### Sử dụng nâng cao

#### Đổi mật khẩu VNC

1. Vào trong container:
   ```bash
   docker exec -it hitomi-downloader bash
   ```

2. Đặt mật khẩu mới:
   ```bash
   x11vnc -storepasswd mat_khau_moi /home/appuser/.vnc/passwd
   ```

3. Khởi động lại container:
   ```bash
   docker restart hitomi-downloader
   ```

#### Sử dụng với Reverse Proxy (Nginx)

Ví dụ cấu hình Nginx:

```nginx
server {
    listen 80;
    server_name hitomi.domain-cua-ban.com;

    location / {
        proxy_pass http://localhost:6080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Xử lý sự cố

#### Container không khởi động

Kiểm tra logs:
```bash
docker logs hitomi-downloader
```

#### Không truy cập được giao diện web

1. Kiểm tra container đang chạy:
   ```bash
   docker ps | grep hitomi-downloader
   ```

2. Kiểm tra port bindings:
   ```bash
   docker port hitomi-downloader
   ```

3. Test dịch vụ noVNC:
   ```bash
   curl http://localhost:6080
   ```

### Dọn dẹp

Xóa container và volumes:
```bash
# Dừng và xóa container
docker-compose down

# Xóa volumes (CẢNH BÁO: Sẽ xóa toàn bộ dữ liệu)
docker-compose down -v

# Xóa image
docker rmi ghcr.io/hoangthinh2024/hitomi-downloader2:latest
```

---

## Support / Hỗ trợ

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the main README.md for general application help

Nếu bạn gặp vấn đề hoặc có câu hỏi:
- Mở issue trên GitHub
- Xem README.md chính để biết hướng dẫn chung về ứng dụng
