@echo off
echo Thiết lập môi trường Visual Studio...

REM Gọi Visual Studio Developer Command Prompt
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" -arch=x64

REM Thêm Git vào PATH
set PATH=C:\Program Files\Git\cmd;%PATH%

REM Kiểm tra Git
echo Kiểm tra Git...
git --version

REM Clean project
echo Cleaning project...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build Windows
echo Building Windows application...
flutter build windows

if %ERRORLEVEL% EQU 0 (
    echo Build thành công!
    
    REM Tạo MSIX package
    echo Tạo MSIX package...
    dart pub global run msix:create store:true
    
    if %ERRORLEVEL% EQU 0 (
        echo MSIX package được tạo thành công!
        
        REM Đổi tên file MSIX
        for %%f in (build\windows\x64\runner\Release\*.msix) do (
            ren "%%f" "Tremo Save Setup.msix"
            echo Đã đổi tên file thành: Tremo Save Setup.msix
        )
    ) else (
        echo Lỗi khi tạo MSIX package
    )
) else (
    echo Build thất bại!
)

echo Nhấn phím bất kỳ để thoát...
pause >nul 