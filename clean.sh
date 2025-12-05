#!/bin/bash
# Script dọn dẹp và giải phóng dung lượng cho dự án Hitomi Downloader
# Cleanup script to free up disk space for Hitomi Downloader project
# Sử dụng / Usage: ./clean.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧹 Bắt đầu dọn dẹp dự án... / Starting project cleanup...${NC}"

# Function to get folder size in MB
get_folder_size() {
    if [ -d "$1" ]; then
        du -sm "$1" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

total_freed=0

# 1. Xóa thư mục target (Rust build artifacts)
target_path="./src-tauri/target"
if [ -d "$target_path" ]; then
    size=$(get_folder_size "$target_path")
    echo -e "${YELLOW}🗑️  Đang xóa src-tauri/target ($size MB)... / Removing src-tauri/target ($size MB)...${NC}"
    rm -rf "$target_path"
    total_freed=$((total_freed + size))
    echo -e "${GREEN}✅ Đã xóa src-tauri/target / Removed src-tauri/target${NC}"
else
    echo -e "${GRAY}⏭️  src-tauri/target không tồn tại / src-tauri/target does not exist${NC}"
fi

# 2. Xóa thư mục node_modules
node_modules_path="./node_modules"
if [ -d "$node_modules_path" ]; then
    size=$(get_folder_size "$node_modules_path")
    echo -e "${YELLOW}🗑️  Đang xóa node_modules ($size MB)... / Removing node_modules ($size MB)...${NC}"
    rm -rf "$node_modules_path"
    total_freed=$((total_freed + size))
    echo -e "${GREEN}✅ Đã xóa node_modules / Removed node_modules${NC}"
else
    echo -e "${GRAY}⏭️  node_modules không tồn tại / node_modules does not exist${NC}"
fi

# 3. Xóa thư mục dist
dist_path="./dist"
if [ -d "$dist_path" ]; then
    size=$(get_folder_size "$dist_path")
    echo -e "${YELLOW}🗑️  Đang xóa dist ($size MB)... / Removing dist ($size MB)...${NC}"
    rm -rf "$dist_path"
    total_freed=$((total_freed + size))
    echo -e "${GREEN}✅ Đã xóa dist / Removed dist${NC}"
else
    echo -e "${GRAY}⏭️  dist không tồn tại / dist does not exist${NC}"
fi

# 4. Xóa thư mục build-output nếu có
build_output_path="./build-output"
if [ -d "$build_output_path" ]; then
    size=$(get_folder_size "$build_output_path")
    echo -e "${YELLOW}🗑️  Đang xóa build-output ($size MB)... / Removing build-output ($size MB)...${NC}"
    rm -rf "$build_output_path"
    total_freed=$((total_freed + size))
    echo -e "${GREEN}✅ Đã xóa build-output / Removed build-output${NC}"
else
    echo -e "${GRAY}⏭️  build-output không tồn tại / build-output does not exist${NC}"
fi

# 5. Xóa các file cache và temp
echo -e "${YELLOW}🗑️  Đang xóa các file cache và temp... / Removing cache and temp files...${NC}"
rm -rf .cache .temp .tmp *.tsbuildinfo 2>/dev/null || true
echo -e "${GREEN}✅ Đã xóa các file cache và temp / Removed cache and temp files${NC}"

echo ""
echo -e "${GREEN}✨ Hoàn tất! Đã giải phóng khoảng $total_freed MB / Done! Freed approximately $total_freed MB${NC}"
echo ""
echo -e "${CYAN}📝 Để khôi phục dự án: / To restore project:${NC}"
echo -e "   ${NC}- Cài lại dependencies / Reinstall dependencies: ${GREEN}pnpm install${NC}"
echo -e "   ${NC}- Build lại project / Rebuild project: ${GREEN}pnpm tauri build${NC} hoặc/or ${GREEN}pnpm tauri dev${NC}"
