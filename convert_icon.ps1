# Script chuyển đổi PNG sang ICO cho Tremo Save
# Yêu cầu: ImageMagick được cài đặt

param(
    [string]$InputFile = "AppIcon.png",
    [string]$OutputFile = "assets\AppIcon.ico"
)

Write-Host "=== Chuyển đổi Icon PNG sang ICO ===" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra ImageMagick
try {
    $magickVersion = & magick -version 2>&1
    Write-Host "✓ ImageMagick found: $($magickVersion[0])" -ForegroundColor Green
}
catch {
    Write-Host "❌ ImageMagick not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vui lòng cài đặt ImageMagick:" -ForegroundColor Yellow
    Write-Host "1. Tải từ: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "2. Hoặc sử dụng Chocolatey: choco install imagemagick" -ForegroundColor Yellow
    Write-Host "3. Hoặc sử dụng công cụ online: https://convertio.co/png-ico/" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Kiểm tra file input
if (-not (Test-Path $InputFile)) {
    Write-Host "❌ File input không tồn tại: $InputFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vui lòng đặt file PNG vào thư mục gốc với tên: $InputFile" -ForegroundColor Yellow
    exit 1
}

# Tạo thư mục output nếu chưa có
if (-not (Test-Path "assets")) {
    New-Item -ItemType Directory -Name "assets" | Out-Null
    Write-Host "✓ Tạo thư mục assets" -ForegroundColor Green
}

Write-Host "🔄 Đang chuyển đổi $InputFile sang $OutputFile..." -ForegroundColor Yellow

try {
    # Chuyển đổi PNG sang ICO với nhiều kích thước
    & magick convert $InputFile -resize 256x256 -define icon:auto-resize=256,128,64,48,32,16 $OutputFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Chuyển đổi thành công!" -ForegroundColor Green
        Write-Host "📁 File ICO đã được tạo tại: $OutputFile" -ForegroundColor Green
        
        # Hiển thị thông tin file
        $fileInfo = Get-Item $OutputFile
        Write-Host "📊 Kích thước file: $($fileInfo.Length) bytes" -ForegroundColor Cyan
        Write-Host "📅 Ngày tạo: $($fileInfo.CreationTime)" -ForegroundColor Cyan
    }
    else {
        Write-Host "❌ Lỗi khi chuyển đổi!" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Hoàn thành! Bây giờ bạn có thể build installer:" -ForegroundColor Green
Write-Host "   .\build_installer.ps1" -ForegroundColor Cyan 