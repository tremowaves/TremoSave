# TremoSave Installer Builder
Write-Host "Building TremoSave Installer..." -ForegroundColor Green

# Check if Inno Setup is installed
try {
    $null = Get-Command iscc -ErrorAction Stop
    Write-Host "✓ Inno Setup found" -ForegroundColor Green
} catch {
    Write-Host "✗ Inno Setup not found in PATH" -ForegroundColor Red
    Write-Host "Please install Inno Setup from: https://jrsoftware.org/isinfo.php" -ForegroundColor Yellow
    Write-Host "After installation, make sure iscc.exe is in your PATH" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Build Flutter Windows app first
Write-Host "Building Flutter Windows app..." -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build Flutter app" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Flutter build completed" -ForegroundColor Green

# Create installer directory if it doesn't exist
if (-not (Test-Path "installer")) {
    New-Item -ItemType Directory -Path "installer" | Out-Null
}

# Build basic installer
Write-Host "Building basic installer..." -ForegroundColor Cyan
iscc installer.iss
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build basic installer" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Basic installer created" -ForegroundColor Green

# Build advanced installer
Write-Host "Building advanced installer..." -ForegroundColor Cyan
iscc installer_advanced.iss
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build advanced installer" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Advanced installer created" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Installers created successfully!" -ForegroundColor Green
Write-Host "- Basic installer: installer\TremoSave_Setup.exe" -ForegroundColor White
Write-Host "- Advanced installer: installer\TremoSave_Setup_v1.0.0.exe" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit" 