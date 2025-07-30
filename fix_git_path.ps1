# Fix Git PATH for Flutter Build
# This script fixes the "Unable to find git in your PATH" error

Write-Host "=== Fixing Git PATH for Flutter Build ===" -ForegroundColor Cyan

# 1. Add Git to PATH permanently
Write-Host "Adding Git to PATH..." -ForegroundColor Yellow
$gitPaths = @(
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\bin"
)

foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$path*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$path", "Machine")
            Write-Host "Added $path to System PATH" -ForegroundColor Green
        } else {
            Write-Host "$path already in System PATH" -ForegroundColor Green
        }
    } else {
        Write-Host "Warning: $path not found" -ForegroundColor Yellow
    }
}

# 2. Add to current session PATH
Write-Host "Adding Git to current session PATH..." -ForegroundColor Yellow
$env:PATH += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"

# 3. Configure safe.directory for Flutter
Write-Host "Configuring Git safe.directory..." -ForegroundColor Yellow
$flutterPath = "H:/FlutterSDK/flutter"
$projectPath = "C:/Users/Tremoman/Downloads/TremoSave"

git config --global --add safe.directory $flutterPath
git config --global --add safe.directory $projectPath

Write-Host "Added safe.directory for Flutter SDK and project" -ForegroundColor Green

# 4. Remove AutoRun registry key if exists
Write-Host "Checking for AutoRun registry key..." -ForegroundColor Yellow
$autoRun = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Command Processor" -Name "AutoRun" -ErrorAction SilentlyContinue
if ($autoRun) {
    Write-Host "Removing AutoRun registry key..." -ForegroundColor Yellow
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Command Processor" -Name "AutoRun"
    Write-Host "AutoRun registry key removed" -ForegroundColor Green
} else {
    Write-Host "No AutoRun registry key found" -ForegroundColor Green
}

# 5. Test Git
Write-Host "Testing Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "Git version: $gitVersion" -ForegroundColor Green
    
    $gitPath = Get-Command git -ErrorAction SilentlyContinue
    if ($gitPath) {
        Write-Host "Git location: $($gitPath.Source)" -ForegroundColor Green
    }
} catch {
    Write-Host "Error: Git not found!" -ForegroundColor Red
}

# 6. Test Flutter
Write-Host "Testing Flutter..." -ForegroundColor Yellow
try {
    flutter doctor -v
    Write-Host "Flutter doctor completed successfully" -ForegroundColor Green
} catch {
    Write-Host "Error: Flutter doctor failed!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Git PATH Fix Complete ===" -ForegroundColor Cyan
Write-Host "Please restart your terminal/IDE and try building again:" -ForegroundColor Yellow
Write-Host "flutter clean" -ForegroundColor White
Write-Host "flutter pub get" -ForegroundColor White
Write-Host "flutter build windows --release" -ForegroundColor White
Write-Host ""
Write-Host "If you still get Git PATH errors, try:" -ForegroundColor Yellow
Write-Host "1. Restart your computer" -ForegroundColor White
Write-Host "2. Run this script as Administrator" -ForegroundColor White
Write-Host "3. Check if Git is properly installed" -ForegroundColor White 