# Hướng dẫn Dọn dẹp và Giải phóng Dung lượng

## 📊 Tổng quan

Dự án này sử dụng nhiều dependencies và tạo ra các build artifacts có thể chiếm nhiều dung lượng đĩa.

### Các thư mục tốn dung lượng:

- **`src-tauri/target/`** (~12-15GB): Rust build artifacts - CÓ THỂ XÓA AN TOÀN
- **`node_modules/`** (~200-300MB): Node.js dependencies - CÓ THỂ XÓA AN TOÀN
- **`dist/`** (~1MB): Build output frontend - CÓ THỂ XÓA AN TOÀN

## 🧹 Cách Dọn dẹp

### Cách 1: Sử dụng script tự động (Khuyến nghị)

#### Windows (PowerShell):
```powershell
.\clean.ps1
```

#### Linux/macOS (Bash):
```bash
./clean.sh
```

Script này sẽ tự động:
- Xóa `src-tauri/target/`
- Xóa `node_modules/`
- Xóa `dist/`
- Xóa các file cache tạm

### Cách 2: Xóa thủ công

#### Windows (PowerShell):
```powershell
# Xóa Rust build artifacts (giải phóng nhiều nhất)
Remove-Item -Path ".\src-tauri\target" -Recurse -Force

# Xóa Node.js dependencies
Remove-Item -Path ".\node_modules" -Recurse -Force

# Xóa build output
Remove-Item -Path ".\dist" -Recurse -Force
```

#### Linux/macOS:
```bash
# Xóa Rust build artifacts
rm -rf ./src-tauri/target

# Xóa Node.js dependencies
rm -rf ./node_modules

# Xóa build output
rm -rf ./dist
```

### Cách 3: Sử dụng cargo clean (chỉ cho Rust)

```bash
cd src-tauri
cargo clean
```

## 🔄 Khôi phục sau khi Dọn dẹp

Sau khi dọn dẹp, bạn cần cài lại dependencies trước khi chạy dự án:

```bash
# Cài lại Node.js dependencies
pnpm install

# Chạy development mode (sẽ tự động build Rust)
pnpm tauri dev

# Hoặc build production
pnpm tauri build
```

## 💡 Mẹo Tối ưu

1. **Chỉ xóa khi cần thiết**: Các thư mục này cần thiết để chạy dự án. Chỉ xóa khi bạn cần giải phóng dung lượng tạm thời.

2. **Build incremental**: Rust sử dụng incremental compilation, giữ lại `target/` sẽ giúp build nhanh hơn lần sau.

3. **pnpm store**: Nếu bạn sử dụng pnpm, dependencies được lưu trong global store nên không tốn nhiều dung lượng như npm/yarn.

4. **Git ignore**: File `.gitignore` đã được cấu hình để không commit các thư mục này lên repository.

## 📦 Kích thước Dự án

**Sau khi dọn dẹp** (chỉ source code):
- Khoảng **1-2 MB**

**Với dependencies**:
- Khoảng **250-300 MB** (với node_modules)

**Với build artifacts**:
- Khoảng **13-15 GB** (với cả node_modules và target)

## ⚠️ Lưu ý

- **KHÔNG XÓA** các thư mục: `src/`, `public/`, `src-tauri/src/`, `src-tauri/icons/`
- Các thư mục trên chứa source code, xóa sẽ làm mất code của bạn!
- File `.gitignore` đã được cấu hình để bảo vệ các thư mục quan trọng

## 🔍 Kiểm tra Kích thước

Để kiểm tra kích thước các thư mục:

```powershell
# Windows
Get-ChildItem -Directory | ForEach-Object { 
    [PSCustomObject]@{
        Name = $_.Name
        SizeMB = [math]::Round((Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    }
} | Sort-Object SizeMB -Descending
```

```bash
# Linux/macOS
du -sh */ | sort -hr
```
