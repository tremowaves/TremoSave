# Tremo Save - Build Installer Script
# PowerShell version

param(
    [switch]$Advanced,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Tremo Save - Build Installer Script

Usage:
    .\build_installer.ps1                    # Build basic installer
    .\build_installer.ps1 -Advanced         # Build advanced installer
    .\build_installer.ps1 -Help             # Show this help

Options:
    -Advanced    Use advanced installer script (installer_advanced.iss)
    -Help        Show this help message

Requirements:
    - Flutter SDK
    - Inno Setup (for automatic building)
"@
    exit 0
}

# Colors for output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Colors[$Color]
}

function Write-Header {
    param([string]$Title)
    Write-Host "`n" -NoNewline
    Write-Host "=" * 60 -ForegroundColor $Colors.Header
    Write-Host "    $Title" -ForegroundColor $Colors.Header
    Write-Host "=" * 60 -ForegroundColor $Colors.Header
    Write-Host ""
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Main execution
Write-Header "Tremo Save - Build Installer"

# Step 1: Check Flutter
Write-ColorOutput "[1/4] Checking Flutter SDK..." "Info"
if (-not (Test-Command "flutter")) {
    Write-ColorOutput "ERROR: Flutter SDK not found in PATH!" "Error"
    Write-ColorOutput "Please install Flutter and add it to PATH" "Error"
    Write-ColorOutput "Download from: https://flutter.dev/docs/get-started/install" "Error"
    exit 1
}
Write-ColorOutput "✓ Flutter SDK found" "Success"

# Step 2: Build Flutter application
Write-ColorOutput "[2/4] Building Flutter application..." "Info"
try {
    $buildResult = & flutter build windows --release 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "ERROR: Flutter build failed!" "Error"
        Write-ColorOutput $buildResult "Error"
        exit 1
    }
    Write-ColorOutput "✓ Flutter build completed successfully!" "Success"
}
catch {
    Write-ColorOutput "ERROR: Failed to build Flutter application" "Error"
    Write-ColorOutput $_.Exception.Message "Error"
    exit 1
}

# Step 3: Check Inno Setup
Write-ColorOutput "[3/4] Checking Inno Setup..." "Info"
if (-not (Test-Command "iscc")) {
    Write-ColorOutput "WARNING: Inno Setup Compiler (ISCC) not found in PATH" "Warning"
    Write-ColorOutput "Please install Inno Setup and add it to PATH" "Warning"
    Write-ColorOutput "Download from: https://jrsoftware.org/isinfo.php" "Warning"
    Write-Host ""
    Write-ColorOutput "You can still build manually using Inno Setup IDE:" "Info"
    Write-ColorOutput "1. Open installer.iss in Inno Setup IDE" "Info"
    Write-ColorOutput "2. Press F9 to compile" "Info"
    Write-Host ""
    Write-ColorOutput "Press any key to continue..." "Info"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-ColorOutput "✓ Inno Setup Compiler found" "Success"

# Step 4: Build installer
Write-ColorOutput "[4/4] Building installer..." "Info"
$scriptFile = if ($Advanced) { "installer_advanced.iss" } else { "installer.iss" }

if (-not (Test-Path $scriptFile)) {
    Write-ColorOutput "ERROR: Installer script not found: $scriptFile" "Error"
    exit 1
}

try {
    $installerResult = & iscc $scriptFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "ERROR: Installer build failed!" "Error"
        Write-ColorOutput $installerResult "Error"
        exit 1
    }
    Write-ColorOutput "✓ Installer built successfully!" "Success"
}
catch {
    Write-ColorOutput "ERROR: Failed to build installer" "Error"
    Write-ColorOutput $_.Exception.Message "Error"
    exit 1
}

# Success message
Write-Header "Build completed successfully!"
Write-ColorOutput "Installer location: installer\TremoSave_Setup.exe" "Success"
if ($Advanced) {
    Write-ColorOutput "Advanced installer with additional features created!" "Info"
}
Write-Host ""
Write-ColorOutput "Press any key to exit..." "Info"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 