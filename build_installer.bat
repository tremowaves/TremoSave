@echo off
echo Building TremoSave Installer...

REM Check if Inno Setup is installed
where iscc >nul 2>&1
if %errorlevel% neq 0 (
    echo Inno Setup not found in PATH.
    echo Please install Inno Setup from: https://jrsoftware.org/isinfo.php
    echo After installation, make sure iscc.exe is in your PATH
    pause
    exit /b 1
)

REM Build Flutter Windows app first
echo Building Flutter Windows app...
flutter build windows --release
if %errorlevel% neq 0 (
    echo Failed to build Flutter app
    pause
    exit /b 1
)

REM Create installer directory if it doesn't exist
if not exist "installer" mkdir installer

REM Build basic installer
echo Building basic installer...
iscc installer.iss
if %errorlevel% neq 0 (
    echo Failed to build basic installer
    pause
    exit /b 1
)

REM Build advanced installer
echo Building advanced installer...
iscc installer_advanced.iss
if %errorlevel% neq 0 (
    echo Failed to build advanced installer
    pause
    exit /b 1
)

echo.
echo Installers created successfully!
echo - Basic installer: installer\TremoSave_Setup.exe
echo - Advanced installer: installer\TremoSave_Setup_v1.0.0.exe
echo.
pause 