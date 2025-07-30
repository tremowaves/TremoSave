@echo off
echo ========================================
echo TremoSave MSIX Installation Script
echo ========================================
echo.

echo Checking for existing installations...
powershell -Command "Get-AppxPackage -Name '*TremoSave*' | Remove-AppxPackage -ErrorAction SilentlyContinue"
powershell -Command "Get-AppxPackage -Name '*auto*' | Where-Object {$_.Name -like '*tremo*'} | Remove-AppxPackage -ErrorAction SilentlyContinue"

echo.
echo Installing TremoSave MSIX package...
echo.

REM Try different installation methods
echo Method 1: Standard installation...
powershell -Command "Add-AppxPackage -Path 'TremoSave_1.0.0.0.msix' -ErrorAction SilentlyContinue"
if %ERRORLEVEL% EQU 0 (
    echo Installation successful!
    goto :success
)

echo Method 2: Unsigned package installation...
powershell -Command "Add-AppxPackage -Path 'TremoSave_1.0.0.0.msix' -AllowUnsigned -ErrorAction SilentlyContinue"
if %ERRORLEVEL% EQU 0 (
    echo Installation successful with unsigned bypass!
    goto :success
)

echo Method 3: Signed package installation...
powershell -Command "Add-AppxPackage -Path 'TremoSave_1.0.0.0_Signed.msix' -ErrorAction SilentlyContinue"
if %ERRORLEVEL% EQU 0 (
    echo Installation successful with signed package!
    goto :success
)

echo Method 4: Force installation...
powershell -Command "Add-AppxPackage -Path 'TremoSave_1.0.0.0.msix' -ForceUpdateFromAnyVersion -ErrorAction SilentlyContinue"
if %ERRORLEVEL% EQU 0 (
    echo Installation successful with force update!
    goto :success
)

echo.
echo ========================================
echo Installation failed!
echo ========================================
echo.
echo Please try the following:
echo 1. Enable Developer Mode in Windows Settings
echo    - Open Settings ^> Update ^& Security ^> For developers
echo    - Select "Developer mode"
echo    - Restart your computer
echo.
echo 2. Or double-click the MSIX file manually:
echo    - TremoSave_1.0.0.0.msix
echo    - TremoSave_1.0.0.0_Signed.msix
echo.
pause
goto :end

:success
echo.
echo ========================================
echo Installation completed successfully!
echo ========================================
echo.
echo TremoSave has been installed with executable name: "Tremo Save.exe"
echo You can find it in the Start Menu or search for "Tremo Save"
echo.
pause

:end 