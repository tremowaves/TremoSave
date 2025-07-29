@echo off
echo ========================================
echo    Tremo Save - Build Installer
echo ========================================
echo.

echo [1/3] Building Flutter application...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)
echo ✓ Flutter build completed successfully!
echo.

echo [2/3] Checking Inno Setup...
where iscc >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Inno Setup Compiler (ISCC) not found in PATH
    echo Please install Inno Setup and add it to PATH
    echo Download from: https://jrsoftware.org/isinfo.php
    echo.
    echo You can still build manually using Inno Setup IDE:
    echo 1. Open installer.iss in Inno Setup IDE
    echo 2. Press F9 to compile
    pause
    exit /b 1
)
echo ✓ Inno Setup Compiler found!
echo.

echo [3/3] Building installer...
iscc installer.iss
if %errorlevel% neq 0 (
    echo ERROR: Installer build failed!
    pause
    exit /b 1
)
echo ✓ Installer built successfully!
echo.

echo ========================================
echo    Build completed successfully!
echo ========================================
echo.
echo Installer location: installer\AutoSaver_Setup.exe
echo.
pause 