@echo off
echo === Building Flutter without Git dependency ===

REM Temporarily disable Git by renaming git.exe
set "GIT_PATH=C:\Program Files\Git\cmd\git.exe"
set "GIT_BACKUP=C:\Program Files\Git\cmd\git.exe.backup"

if exist "%GIT_PATH%" (
    echo Temporarily renaming git.exe...
    ren "%GIT_PATH%" "git.exe.backup"
    echo Git temporarily disabled
) else (
    echo Git not found at expected location
)

REM Clean and build
echo Cleaning Flutter project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building Windows application...
flutter build windows --release

REM Restore Git
if exist "%GIT_BACKUP%" (
    echo Restoring git.exe...
    ren "%GIT_BACKUP%" "git.exe"
    echo Git restored
)

echo === Build process completed ===
pause 