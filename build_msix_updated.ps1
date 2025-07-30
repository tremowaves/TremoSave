# TremoSave MSIX Build Script (Updated)
# Build MSIX package with updated publisher information

param(
    [string]$Version = "1.0.0.0",
    [string]$Architecture = "x64"
)

Write-Host "=== TremoSave MSIX Build Script (Updated) ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Architecture: $Architecture" -ForegroundColor Yellow
Write-Host ""

# Check if Flutter build exists
$appSource = "build\windows\x64\runner\Release"
if (-not (Test-Path $appSource)) {
    Write-Host "Error: Flutter build not found at $appSource" -ForegroundColor Red
    Write-Host "Please run 'flutter build windows --release' first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Using existing Flutter build from: $appSource" -ForegroundColor Green

# Create MSIX package
Write-Host "Creating MSIX package..." -ForegroundColor Cyan
$msixOutput = "build\windows\msix"

# Clean previous MSIX build
if (Test-Path $msixOutput) {
    Write-Host "Cleaning previous MSIX build..." -ForegroundColor Cyan
    Remove-Item $msixOutput -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $msixOutput -Force | Out-Null

# Copy built application files to root of MSIX package
Write-Host "Copying application files..." -ForegroundColor Cyan
Copy-Item -Path "$appSource\*" -Destination $msixOutput -Recurse -Force

# Rename auto_saver.exe to "Tremo Save.exe"
Write-Host "Renaming executable..." -ForegroundColor Cyan
if (Test-Path "$msixOutput\auto_saver.exe") {
    Rename-Item -Path "$msixOutput\auto_saver.exe" -NewName "Tremo Save.exe"
    Write-Host "Renamed auto_saver.exe to 'Tremo Save.exe'" -ForegroundColor Green
} else {
    Write-Host "Warning: auto_saver.exe not found!" -ForegroundColor Yellow
}

# Create assets directory and copy icon
Write-Host "Copying assets..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "$msixOutput\assets" -Force | Out-Null

# Check for PNG logo first, then fallback to ICO
$logoPath = ""
if (Test-Path "assets\AppIcon.png") {
    Copy-Item -Path "assets\AppIcon.png" -Destination "$msixOutput\assets\" -Force
    $logoPath = "assets\AppIcon.png"
} elseif (Test-Path "assets\AppIcon.ico") {
    Copy-Item -Path "assets\AppIcon.ico" -Destination "$msixOutput\assets\" -Force
    $logoPath = "assets\AppIcon.png"  # Use PNG path even for ICO file
    Write-Host "Warning: Using ICO file as PNG for MSIX compatibility" -ForegroundColor Yellow
} else {
    Write-Host "Warning: No logo file found, using default" -ForegroundColor Yellow
    $logoPath = "assets\AppIcon.png"
}

# Create AppxManifest.xml with updated publisher information
Write-Host "Creating AppxManifest.xml with updated publisher..." -ForegroundColor Cyan
$manifest = @"
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10" 
         xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
         xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"
         IgnorableNamespaces="uap rescap">
  <Identity Name="TremoSave" Publisher="CN=D7F81022-3149-447F-B2A2-C1988B66E58A" Version="$Version" />
  <Properties>
    <DisplayName>Tremo Save Setup</DisplayName>
    <PublisherDisplayName>Tremowaves</PublisherDisplayName>
    <Logo>$logoPath</Logo>
  </Properties>
  <Dependencies>
    <TargetDeviceFamily Name="Windows.Desktop" MinVersion="10.0.17763.0" MaxVersionTested="10.0.19041.0" />
  </Dependencies>
  <Resources>
    <Resource Language="en-us" />
  </Resources>
  <Applications>
    <Application Id="App" Executable="Tremo Save.exe" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements DisplayName="Tremo Save Setup" 
                          Description="Auto save application for Windows"
                          BackgroundColor="transparent"
                          Square150x150Logo="$logoPath"
                          Square44x44Logo="$logoPath">
        <uap:DefaultTile Wide310x150Logo="$logoPath" />
      </uap:VisualElements>
    </Application>
  </Applications>
  <Capabilities>
    <Capability Name="internetClient" />
    <rescap:Capability Name="runFullTrust" />
  </Capabilities>
</Package>
"@

Set-Content -Path "$msixOutput\AppxManifest.xml" -Value $manifest -Encoding UTF8

# Create MSIX package using MakeAppx
Write-Host "Creating MSIX package using MakeAppx..." -ForegroundColor Cyan
$msixFile = "TremoSave_1.0.0.0_Updated.msix"
$makeAppxPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64\MakeAppx.exe"

if (Test-Path $makeAppxPath) {
    & $makeAppxPath pack /d "$msixOutput" /p "$msixFile" /l
    if ($LASTEXITCODE -eq 0) {
        Write-Host "MSIX package created successfully: $msixFile" -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to create MSIX package!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Warning: MakeAppx.exe not found. Please install Windows SDK." -ForegroundColor Yellow
    Write-Host "MSIX package structure created in: $msixOutput" -ForegroundColor Yellow
}

# Create installer script
Write-Host "Creating installer script..." -ForegroundColor Cyan
$installerScript = @"
@echo off
echo Installing TremoSave MSIX package with updated publisher...
powershell -Command "Add-AppxPackage -Path '$msixFile'"
if %ERRORLEVEL% EQU 0 (
    echo Installation completed successfully!
) else (
    echo Installation failed!
)
pause
"@

Set-Content -Path "install_msix_updated.bat" -Value $installerScript -Encoding ASCII

Write-Host ""
Write-Host "=== Build Summary ===" -ForegroundColor Cyan
Write-Host "MSIX Package: $msixFile" -ForegroundColor Green
Write-Host "Installer Script: install_msix_updated.bat" -ForegroundColor Green
Write-Host "Package Location: $msixOutput" -ForegroundColor Green
Write-Host "Executable Name: Tremo Save.exe" -ForegroundColor Green
Write-Host "Publisher: CN=D7F81022-3149-447F-B2A2-C1988B66E58A" -ForegroundColor Green
Write-Host "Publisher Display Name: Tremowaves" -ForegroundColor Green
Write-Host ""
Write-Host "To install the package, run: .\install_msix_updated.bat" -ForegroundColor Yellow 