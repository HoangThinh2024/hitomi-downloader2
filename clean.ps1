# Script dọn dẹp và giải phóng dung lượng cho dự án Hitomi Downloader
# Sử dụng: .\clean.ps1

Write-Host "🧹 Bắt đầu dọn dẹp dự án..." -ForegroundColor Cyan

# Hàm tính kích thước thư mục
function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

$totalFreed = 0

# 1. Xóa thư mục target (Rust build artifacts)
$targetPath = ".\src-tauri\target"
if (Test-Path $targetPath) {
    $size = Get-FolderSize $targetPath
    Write-Host "🗑️  Đang xóa src-tauri/target ($size MB)..." -ForegroundColor Yellow
    Remove-Item $targetPath -Recurse -Force -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "✅ Đã xóa src-tauri/target" -ForegroundColor Green
} else {
    Write-Host "⏭️  src-tauri/target không tồn tại" -ForegroundColor Gray
}

# 2. Xóa thư mục node_modules
$nodeModulesPath = ".\node_modules"
if (Test-Path $nodeModulesPath) {
    $size = Get-FolderSize $nodeModulesPath
    Write-Host "🗑️  Đang xóa node_modules ($size MB)..." -ForegroundColor Yellow
    Remove-Item $nodeModulesPath -Recurse -Force -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "✅ Đã xóa node_modules" -ForegroundColor Green
} else {
    Write-Host "⏭️  node_modules không tồn tại" -ForegroundColor Gray
}

# 3. Xóa thư mục dist
$distPath = ".\dist"
if (Test-Path $distPath) {
    $size = Get-FolderSize $distPath
    Write-Host "🗑️  Đang xóa dist ($size MB)..." -ForegroundColor Yellow
    Remove-Item $distPath -Recurse -Force -ErrorAction SilentlyContinue
    $totalFreed += $size
    Write-Host "✅ Đã xóa dist" -ForegroundColor Green
} else {
    Write-Host "⏭️  dist không tồn tại" -ForegroundColor Gray
}

# 4. Xóa các file cache và temp
$cacheFiles = @(
    ".cache",
    ".temp",
    ".tmp",
    "*.tsbuildinfo"
)

foreach ($pattern in $cacheFiles) {
    $files = Get-ChildItem -Path . -Filter $pattern -Recurse -ErrorAction SilentlyContinue
    if ($files) {
        foreach ($file in $files) {
            Write-Host "🗑️  Đang xóa $($file.Name)..." -ForegroundColor Yellow
            Remove-Item $file.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host ""
Write-Host "✨ Hoàn tất! Đã giải phóng khoảng $totalFreed MB" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Để khôi phục dự án:" -ForegroundColor Cyan
Write-Host "   - Cài lại dependencies: pnpm install" -ForegroundColor White
Write-Host "   - Build lại project: pnpm tauri build hoặc pnpm tauri dev" -ForegroundColor White
