# Ubuntu Build & Installation Guide
# Hướng dẫn Build và Cài đặt trên Ubuntu

[English](#english) | [Tiếng Việt](#tiếng-việt)

---

## English

### 📋 Overview

This guide provides instructions for building, installing, and uninstalling Hitomi Downloader on Ubuntu. The build process is optimized to:
- ✅ Create a working application
- ✅ Automatically clean up build artifacts (saves ~13-15GB)
- ✅ Provide easy installation and uninstallation
- ✅ Keep your system light and clean

### 🔧 Prerequisites

Before building, ensure you have the following installed:

1. **Rust**: Install from [rustup.rs](https://rustup.rs/)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   ```

2. **Node.js**: Install from [nodejs.org](https://nodejs.org/) or using package manager
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **pnpm**: Install via npm
   ```bash
   npm install -g pnpm
   ```

4. **System dependencies** (Ubuntu/Debian):
   ```bash
   sudo apt-get update
   sudo apt-get install -y \
       libwebkit2gtk-4.1-dev \
       libappindicator3-dev \
       librsvg2-dev \
       patchelf \
       build-essential \
       curl \
       wget \
       file
   ```

### 🚀 Quick Start

#### Option 1: Automated Build Script (Recommended)

The `build-ubuntu.sh` script handles everything automatically:

```bash
# Make the script executable
chmod +x build-ubuntu.sh

# Run the build script
./build-ubuntu.sh
```

**What it does:**
1. ✅ Checks for required tools
2. ✅ Installs dependencies
3. ✅ Builds the application
4. ✅ Copies the built app to `build-output/` directory
5. ✅ Cleans up build artifacts (~13-15GB freed)
6. ✅ Creates installation and uninstallation scripts

**After building**, you'll find the application and scripts in the `build-output/` directory:
- `hitomi-downloader` - The application binary
- `*.deb` - Debian package (if generated)
- `*.AppImage` - AppImage package (if generated)
- `install.sh` - Installation script
- `uninstall.sh` - Uninstallation script

#### Option 2: Manual Build

If you prefer manual control:

```bash
# 1. Install dependencies
pnpm install

# 2. Build the application
pnpm tauri build

# 3. Find the built artifacts
# Binary: src-tauri/target/release/hitomi-downloader
# DEB: src-tauri/target/release/bundle/deb/*.deb
# AppImage: src-tauri/target/release/bundle/appimage/*.AppImage
```

### 📦 Installation

#### Using the Installation Script (Recommended)

```bash
cd build-output

# Install for current user only
./install.sh

# OR install system-wide (requires sudo)
sudo ./install.sh
```

**What the script does:**
- Copies the binary to a system directory
- Creates a desktop entry for GUI access
- Creates a symlink so you can run `hitomi-downloader` from terminal

**Installation locations:**
- **User installation**: `~/.local/share/hitomi-downloader/`
- **System-wide installation**: `/opt/hitomi-downloader/`

#### Using DEB Package

If a `.deb` package was generated:

```bash
cd build-output
sudo dpkg -i *.deb
sudo apt-get install -f  # Install any missing dependencies
```

#### Using AppImage

If an `.AppImage` was generated:

```bash
cd build-output
chmod +x *.AppImage
./*.AppImage  # Run directly, no installation needed
```

### ▶️ Running the Application

After installation, you can run the application in three ways:

1. **From terminal:**
   ```bash
   hitomi-downloader
   ```

2. **From application menu:**
   - Search for "Hitomi Downloader" in your application launcher

3. **From file manager:**
   - Navigate to the installation directory and double-click the binary

### 🗑️ Uninstallation

#### Using the Uninstallation Script

```bash
cd build-output

# If installed for current user
./uninstall.sh

# If installed system-wide
sudo ./uninstall.sh
```

#### Using DEB Package

If installed via DEB package:

```bash
sudo apt-get remove hitomi-downloader
# or
sudo dpkg -r hitomi-downloader
```

**Note:** Your downloaded files will NOT be removed during uninstallation.

### 🧹 Cleaning Up Build Artifacts

If you want to clean up the build directories without rebuilding:

```bash
# Using the cleanup script
./clean.sh

# Or manually
rm -rf src-tauri/target node_modules dist build-output
```

This will free up approximately **13-15GB** of disk space.

### 📊 Disk Space Summary

- **Source code only**: ~1-2 MB
- **With dependencies**: ~250-300 MB
- **With build artifacts**: ~13-15 GB
- **Built application**: ~10-20 MB
- **After cleanup**: Back to ~1-2 MB (keeping only the app)

### 🔍 Troubleshooting

#### Build Fails

1. **Check prerequisites:**
   ```bash
   node --version
   pnpm --version
   cargo --version
   ```

2. **Install missing system dependencies:**
   ```bash
   sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf
   ```

3. **Clean and rebuild:**
   ```bash
   ./clean.sh
   ./build-ubuntu.sh
   ```

#### Application Won't Start

1. **Check if binary is executable:**
   ```bash
   chmod +x build-output/hitomi-downloader
   ```

2. **Run from terminal to see error messages:**
   ```bash
   ./build-output/hitomi-downloader
   ```

3. **Check system dependencies:**
   ```bash
   ldd build-output/hitomi-downloader
   ```

### 🎯 Performance Tips

For optimal performance on Ubuntu:
- Use SSD storage for downloads
- Ensure adequate RAM (4GB+ recommended)
- Keep system updated
- See [LINUX_OPTIMIZATION.md](./LINUX_OPTIMIZATION.md) for detailed optimizations

---

## Tiếng Việt

### 📋 Tổng quan

Hướng dẫn này cung cấp các chỉ dẫn để build, cài đặt và gỡ bỏ Hitomi Downloader trên Ubuntu. Quá trình build được tối ưu để:
- ✅ Tạo ra ứng dụng hoạt động tốt
- ✅ Tự động dọn dẹp các file build (tiết kiệm ~13-15GB)
- ✅ Cung cấp cài đặt và gỡ bỏ dễ dàng
- ✅ Giữ hệ thống nhẹ và sạch sẽ

### 🔧 Yêu cầu

Trước khi build, đảm bảo bạn đã cài đặt:

1. **Rust**: Cài từ [rustup.rs](https://rustup.rs/)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   ```

2. **Node.js**: Cài từ [nodejs.org](https://nodejs.org/) hoặc dùng package manager
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **pnpm**: Cài qua npm
   ```bash
   npm install -g pnpm
   ```

4. **Các dependencies hệ thống** (Ubuntu/Debian):
   ```bash
   sudo apt-get update
   sudo apt-get install -y \
       libwebkit2gtk-4.1-dev \
       libappindicator3-dev \
       librsvg2-dev \
       patchelf \
       build-essential \
       curl \
       wget \
       file
   ```

### 🚀 Bắt đầu nhanh

#### Phương án 1: Script Build Tự động (Khuyến nghị)

Script `build-ubuntu.sh` xử lý mọi thứ tự động:

```bash
# Cấp quyền thực thi cho script
chmod +x build-ubuntu.sh

# Chạy script build
./build-ubuntu.sh
```

**Nó làm gì:**
1. ✅ Kiểm tra các công cụ cần thiết
2. ✅ Cài đặt dependencies
3. ✅ Build ứng dụng
4. ✅ Sao chép app đã build vào thư mục `build-output/`
5. ✅ Dọn dẹp các file build (~13-15GB được giải phóng)
6. ✅ Tạo script cài đặt và gỡ bỏ

**Sau khi build**, bạn sẽ tìm thấy ứng dụng và các script trong thư mục `build-output/`:
- `hitomi-downloader` - File binary của ứng dụng
- `*.deb` - Gói Debian (nếu được tạo)
- `*.AppImage` - Gói AppImage (nếu được tạo)
- `install.sh` - Script cài đặt
- `uninstall.sh` - Script gỡ bỏ

#### Phương án 2: Build Thủ công

Nếu bạn muốn kiểm soát thủ công:

```bash
# 1. Cài đặt dependencies
pnpm install

# 2. Build ứng dụng
pnpm tauri build

# 3. Tìm file đã build
# Binary: src-tauri/target/release/hitomi-downloader
# DEB: src-tauri/target/release/bundle/deb/*.deb
# AppImage: src-tauri/target/release/bundle/appimage/*.AppImage
```

### 📦 Cài đặt

#### Dùng Script Cài đặt (Khuyến nghị)

```bash
cd build-output

# Cài cho user hiện tại
./install.sh

# HOẶC cài cho toàn hệ thống (cần sudo)
sudo ./install.sh
```

**Script làm gì:**
- Sao chép binary vào thư mục hệ thống
- Tạo desktop entry để truy cập qua GUI
- Tạo symlink để có thể chạy `hitomi-downloader` từ terminal

**Vị trí cài đặt:**
- **Cài đặt user**: `~/.local/share/hitomi-downloader/`
- **Cài đặt toàn hệ thống**: `/opt/hitomi-downloader/`

#### Dùng Gói DEB

Nếu gói `.deb` được tạo ra:

```bash
cd build-output
sudo dpkg -i *.deb
sudo apt-get install -f  # Cài các dependencies còn thiếu
```

#### Dùng AppImage

Nếu `.AppImage` được tạo ra:

```bash
cd build-output
chmod +x *.AppImage
./*.AppImage  # Chạy trực tiếp, không cần cài đặt
```

### ▶️ Chạy Ứng dụng

Sau khi cài đặt, bạn có thể chạy ứng dụng bằng ba cách:

1. **Từ terminal:**
   ```bash
   hitomi-downloader
   ```

2. **Từ menu ứng dụng:**
   - Tìm "Hitomi Downloader" trong trình khởi chạy ứng dụng

3. **Từ file manager:**
   - Vào thư mục cài đặt và double-click file binary

### 🗑️ Gỡ bỏ

#### Dùng Script Gỡ bỏ

```bash
cd build-output

# Nếu cài cho user hiện tại
./uninstall.sh

# Nếu cài cho toàn hệ thống
sudo ./uninstall.sh
```

#### Dùng Gói DEB

Nếu cài qua gói DEB:

```bash
sudo apt-get remove hitomi-downloader
# hoặc
sudo dpkg -r hitomi-downloader
```

**Lưu ý:** Các file đã tải xuống sẽ KHÔNG bị xóa khi gỡ bỏ.

### 🧹 Dọn dẹp các File Build

Nếu bạn muốn dọn dẹp thư mục build mà không build lại:

```bash
# Dùng script dọn dẹp
./clean.sh

# Hoặc thủ công
rm -rf src-tauri/target node_modules dist build-output
```

Điều này sẽ giải phóng khoảng **13-15GB** dung lượng đĩa.

### 📊 Tổng kết Dung lượng

- **Chỉ source code**: ~1-2 MB
- **Với dependencies**: ~250-300 MB
- **Với build artifacts**: ~13-15 GB
- **Ứng dụng đã build**: ~10-20 MB
- **Sau khi dọn dẹp**: Về lại ~1-2 MB (chỉ giữ app)

### 🔍 Xử lý Sự cố

#### Build Thất bại

1. **Kiểm tra yêu cầu:**
   ```bash
   node --version
   pnpm --version
   cargo --version
   ```

2. **Cài các dependencies hệ thống còn thiếu:**
   ```bash
   sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf
   ```

3. **Dọn dẹp và build lại:**
   ```bash
   ./clean.sh
   ./build-ubuntu.sh
   ```

#### Ứng dụng Không Khởi động

1. **Kiểm tra binary có quyền thực thi:**
   ```bash
   chmod +x build-output/hitomi-downloader
   ```

2. **Chạy từ terminal để xem thông báo lỗi:**
   ```bash
   ./build-output/hitomi-downloader
   ```

3. **Kiểm tra dependencies hệ thống:**
   ```bash
   ldd build-output/hitomi-downloader
   ```

### 🎯 Mẹo Tối ưu Hiệu suất

Để có hiệu suất tốt nhất trên Ubuntu:
- Dùng SSD cho thư mục tải xuống
- Đảm bảo RAM đủ (khuyến nghị 4GB+)
- Giữ hệ thống được cập nhật
- Xem [LINUX_OPTIMIZATION.md](./LINUX_OPTIMIZATION.md) để biết chi tiết về tối ưu hóa

---

## 📝 Additional Notes

### Build Artifacts Location

After running `pnpm tauri build`, artifacts are located at:
- **Binary**: `src-tauri/target/release/hitomi-downloader`
- **DEB package**: `src-tauri/target/release/bundle/deb/`
- **AppImage**: `src-tauri/target/release/bundle/appimage/`

### Security

The application is built with security in mind:
- Written in Rust for memory safety
- Uses Tauri for sandboxed environment
- HTTPS/TLS for all network communications

For security concerns, see [SECURITY.md](./SECURITY.md)

### Contributing

Contributions are welcome! See [README.md](./README.md) for guidelines.

### License

See [LICENSE](./LICENSE) file for details.
