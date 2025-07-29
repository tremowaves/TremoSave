@echo off
echo Building Flutter Windows application...

REM Thiết lập môi trường Visual Studio
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat" -arch=x64

REM Thêm Git vào PATH
set PATH=C:\Program Files\Git\cmd;%PATH%

REM Build
flutter build windows

if %ERRORLEVEL% EQU 0 (
    echo Build thành công!
    
    REM Tạo MSIX
    echo Tạo MSIX package...
    dart pub global run msix:create store:true
    
    if %ERRORLEVEL% EQU 0 (
        echo MSIX package được tạo thành công!
        
        REM Đổi tên
        for %%f in (build\windows\x64\runner\Release\*.msix) do (
            ren "%%f" "Tremo Save Setup.msix"
            echo Đã đổi tên thành: Tremo Save Setup.msix
        )
    )
) else (
    echo Build thất bại!
)

pause 