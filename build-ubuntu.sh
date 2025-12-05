#!/bin/bash
# Build script for Ubuntu - Xây dựng ứng dụng trên Ubuntu
# Script này sẽ build app và tự động dọn dẹp các thư mục build để giảm dung lượng
# This script builds the app and automatically cleans up build directories to reduce disk usage

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get directory size in MB
get_dir_size() {
    if [ -d "$1" ]; then
        du -sm "$1" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Function to check if required tools are installed
check_requirements() {
    print_info "Kiểm tra các công cụ cần thiết / Checking required tools..."
    
    local missing_tools=()
    
    if ! command -v node &> /dev/null; then
        missing_tools+=("nodejs")
    fi
    
    if ! command -v pnpm &> /dev/null; then
        missing_tools+=("pnpm")
    fi
    
    if ! command -v cargo &> /dev/null; then
        missing_tools+=("rust/cargo")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Thiếu các công cụ sau / Missing required tools: ${missing_tools[*]}"
        print_info "Vui lòng cài đặt / Please install:"
        print_info "  - Node.js: https://nodejs.org/"
        print_info "  - pnpm: npm install -g pnpm"
        print_info "  - Rust: https://rustup.rs/"
        exit 1
    fi
    
    print_success "Tất cả các công cụ đã được cài đặt / All required tools are installed"
}

# Function to install dependencies
install_dependencies() {
    print_info "Cài đặt dependencies / Installing dependencies..."
    
    if [ ! -d "node_modules" ]; then
        pnpm install
        print_success "Dependencies đã được cài đặt / Dependencies installed"
    else
        print_info "Dependencies đã tồn tại, bỏ qua / Dependencies already exist, skipping"
    fi
}

# Function to build the application
build_app() {
    print_info "Bắt đầu build ứng dụng / Starting application build..."
    print_info "Quá trình này có thể mất vài phút / This may take several minutes..."
    
    # Build the application
    pnpm tauri build
    
    if [ $? -eq 0 ]; then
        print_success "Build ứng dụng thành công / Application built successfully"
    else
        print_error "Build thất bại / Build failed"
        exit 1
    fi
}

# Function to prepare output directory
prepare_output_dir() {
    OUTPUT_DIR="./build-output"
    
    print_info "Chuẩn bị thư mục output / Preparing output directory..."
    
    # Remove old output directory if exists
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    print_success "Đã tạo thư mục: $OUTPUT_DIR / Created directory: $OUTPUT_DIR"
}

# Function to copy built artifacts
copy_artifacts() {
    print_info "Sao chép file ứng dụng / Copying application files..."
    
    BUNDLE_DIR="src-tauri/target/release/bundle"
    
    # Copy AppImage if exists
    if [ -d "$BUNDLE_DIR/appimage" ]; then
        cp -r "$BUNDLE_DIR/appimage"/*.AppImage "$OUTPUT_DIR/" 2>/dev/null || true
        print_success "Đã sao chép AppImage / Copied AppImage"
    fi
    
    # Copy DEB package if exists
    if [ -d "$BUNDLE_DIR/deb" ]; then
        cp -r "$BUNDLE_DIR/deb"/*.deb "$OUTPUT_DIR/" 2>/dev/null || true
        print_success "Đã sao chép gói DEB / Copied DEB package"
    fi
    
    # Copy binary
    if [ -f "src-tauri/target/release/hitomi-downloader" ]; then
        cp "src-tauri/target/release/hitomi-downloader" "$OUTPUT_DIR/"
        chmod +x "$OUTPUT_DIR/hitomi-downloader"
        print_success "Đã sao chép binary / Copied binary"
    fi
    
    # Check if any files were copied
    if [ -z "$(ls -A $OUTPUT_DIR)" ]; then
        print_error "Không tìm thấy file build nào / No build artifacts found"
        exit 1
    fi
}

# Function to clean up build directories
cleanup_build_dirs() {
    print_info "Bắt đầu dọn dẹp / Starting cleanup..."
    
    total_freed=0
    
    # Clean up target directory
    if [ -d "src-tauri/target" ]; then
        size=$(get_dir_size "src-tauri/target")
        print_info "Đang xóa src-tauri/target ($size MB)..."
        rm -rf src-tauri/target
        total_freed=$((total_freed + size))
        print_success "Đã xóa src-tauri/target / Removed src-tauri/target"
    fi
    
    # Clean up node_modules
    if [ -d "node_modules" ]; then
        size=$(get_dir_size "node_modules")
        print_info "Đang xóa node_modules ($size MB)..."
        rm -rf node_modules
        total_freed=$((total_freed + size))
        print_success "Đã xóa node_modules / Removed node_modules"
    fi
    
    # Clean up dist
    if [ -d "dist" ]; then
        size=$(get_dir_size "dist")
        print_info "Đang xóa dist ($size MB)..."
        rm -rf dist
        total_freed=$((total_freed + size))
        print_success "Đã xóa dist / Removed dist"
    fi
    
    # Clean up other temporary files
    print_info "Dọn dẹp các file tạm / Cleaning up temporary files..."
    rm -rf .cache .temp .tmp *.tsbuildinfo 2>/dev/null || true
    
    print_success "Đã giải phóng ~${total_freed} MB / Freed ~${total_freed} MB"
}

# Function to create installation script
create_install_script() {
    print_info "Tạo script cài đặt / Creating installation script..."
    
    cat > "$OUTPUT_DIR/install.sh" << 'EOF'
#!/bin/bash
# Installation script for Hitomi Downloader

set -e

# Check if running as root for system-wide installation
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/opt/hitomi-downloader"
    DESKTOP_FILE="/usr/share/applications/hitomi-downloader.desktop"
    BIN_LINK="/usr/local/bin/hitomi-downloader"
else
    INSTALL_DIR="$HOME/.local/share/hitomi-downloader"
    DESKTOP_FILE="$HOME/.local/share/applications/hitomi-downloader.desktop"
    BIN_LINK="$HOME/.local/bin/hitomi-downloader"
fi

echo "Installing Hitomi Downloader..."

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$DESKTOP_FILE")"
mkdir -p "$(dirname "$BIN_LINK")"

# Copy binary
if [ -f "./hitomi-downloader" ]; then
    cp ./hitomi-downloader "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/hitomi-downloader"
    echo "Binary installed to: $INSTALL_DIR"
fi

# Create symlink
ln -sf "$INSTALL_DIR/hitomi-downloader" "$BIN_LINK"
echo "Symlink created: $BIN_LINK"

# Create desktop entry
cat > "$DESKTOP_FILE" << DESKTOP
[Desktop Entry]
Name=Hitomi Downloader
Comment=A GUI-based multi-threaded downloader for hitomi.la
Exec=$INSTALL_DIR/hitomi-downloader
Icon=applications-internet
Terminal=false
Type=Application
Categories=Network;FileTransfer;
DESKTOP

echo "Desktop entry created: $DESKTOP_FILE"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    if [ "$EUID" -eq 0 ]; then
        update-desktop-database /usr/share/applications
    else
        update-desktop-database "$HOME/.local/share/applications"
    fi
fi

echo ""
echo "Installation complete!"
echo "You can now run the application by:"
echo "  1. Running 'hitomi-downloader' from terminal"
echo "  2. Searching for 'Hitomi Downloader' in your application menu"
echo ""
echo "To uninstall, run: ./uninstall.sh"
EOF
    
    chmod +x "$OUTPUT_DIR/install.sh"
    print_success "Đã tạo install.sh / Created install.sh"
}

# Function to create uninstallation script
create_uninstall_script() {
    print_info "Tạo script gỡ cài đặt / Creating uninstallation script..."
    
    cat > "$OUTPUT_DIR/uninstall.sh" << 'EOF'
#!/bin/bash
# Uninstallation script for Hitomi Downloader

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/opt/hitomi-downloader"
    DESKTOP_FILE="/usr/share/applications/hitomi-downloader.desktop"
    BIN_LINK="/usr/local/bin/hitomi-downloader"
else
    INSTALL_DIR="$HOME/.local/share/hitomi-downloader"
    DESKTOP_FILE="$HOME/.local/share/applications/hitomi-downloader.desktop"
    BIN_LINK="$HOME/.local/bin/hitomi-downloader"
fi

echo "Uninstalling Hitomi Downloader..."

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed: $INSTALL_DIR"
fi

# Remove desktop entry
if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    echo "Removed: $DESKTOP_FILE"
fi

# Remove symlink
if [ -L "$BIN_LINK" ]; then
    rm -f "$BIN_LINK"
    echo "Removed: $BIN_LINK"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    if [ "$EUID" -eq 0 ]; then
        update-desktop-database /usr/share/applications
    else
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
fi

echo ""
echo "Hitomi Downloader has been uninstalled."
echo "Your download files have NOT been removed."
EOF
    
    chmod +x "$OUTPUT_DIR/uninstall.sh"
    print_success "Đã tạo uninstall.sh / Created uninstall.sh"
}

# Function to display summary
display_summary() {
    echo ""
    echo "========================================"
    echo "🎉 BUILD HOÀN THÀNH / BUILD COMPLETE 🎉"
    echo "========================================"
    echo ""
    print_info "Các file ứng dụng nằm trong / Application files are in: $OUTPUT_DIR"
    echo ""
    print_info "Nội dung thư mục / Directory contents:"
    ls -lh "$OUTPUT_DIR"
    echo ""
    print_info "Hướng dẫn cài đặt / Installation instructions:"
    echo "  1. cd $OUTPUT_DIR"
    echo "  2. ./install.sh           # Cài đặt cho user hiện tại / Install for current user"
    echo "  3. sudo ./install.sh      # Cài đặt cho toàn hệ thống / Install system-wide"
    echo ""
    print_info "Để gỡ cài đặt / To uninstall:"
    echo "  ./uninstall.sh            # hoặc / or: sudo ./uninstall.sh"
    echo ""
    print_info "Hoặc cài đặt gói DEB (nếu có) / Or install DEB package (if available):"
    echo "  sudo dpkg -i $OUTPUT_DIR/*.deb"
    echo "  sudo apt-get install -f"
    echo ""
}

# Main execution
main() {
    echo "========================================"
    echo "   Build Script for Ubuntu"
    echo "   Hitomi Downloader"
    echo "========================================"
    echo ""
    
    check_requirements
    install_dependencies
    build_app
    prepare_output_dir
    copy_artifacts
    cleanup_build_dirs
    create_install_script
    create_uninstall_script
    display_summary
    
    print_success "Tất cả đã hoàn thành! / All done!"
}

# Run main function
main
