# Script để build ứng dụng Flutter Windows
Write-Host "Thiết lập môi trường build..." -ForegroundColor Green

# Thêm Git vào PATH
$env:PATH += ";C:\Program Files\Git\cmd"

# Kiểm tra Git
Write-Host "Kiểm tra Git..." -ForegroundColor Yellow
git --version

# Clean project
Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build Windows
Write-Host "Building Windows application..." -ForegroundColor Yellow
flutter build windows

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build thành công!" -ForegroundColor Green
    
    # Tạo MSIX package với icon và tên tùy chỉnh
    Write-Host "Tạo MSIX package..." -ForegroundColor Yellow
    
    # Tạo MSIX package với cấu hình tùy chỉnh
    dart pub global run msix:create store:true
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "MSIX package được tạo thành công!" -ForegroundColor Green
        
        # Đổi tên file MSIX
        $msixFile = Get-ChildItem "build\windows\x64\runner\Release\*.msix" | Select-Object -First 1
        if ($msixFile) {
            $newName = "Tremo Save Setup.msix"
            $newPath = Join-Path $msixFile.Directory.FullName $newName
            Move-Item $msixFile.FullName $newPath
            Write-Host "Đã đổi tên file thành: $newName" -ForegroundColor Green
        }
    } else {
        Write-Host "Lỗi khi tạo MSIX package" -ForegroundColor Red
    }
} else {
    Write-Host "Build thất bại!" -ForegroundColor Red
}

Write-Host "Nhấn phím bất kỳ để thoát..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 