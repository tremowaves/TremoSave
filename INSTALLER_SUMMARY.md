# Tóm tắt Installer cho Tremo Save

## Các file đã được tạo

### 1. Scripts Inno Setup
- **`installer.iss`** - Script cơ bản cho installer
- **`installer_advanced.iss`** - Script nâng cao với nhiều tính năng hơn

### 2. Scripts Build tự động
- **`build_installer.bat`** - Script batch để build tự động
- **`build_installer.ps1`** - Script PowerShell với giao diện đẹp hơn

### 3. Tài liệu
- **`README_INSTALLER.md`** - Hướng dẫn chi tiết
- **`INSTALLER_SUMMARY.md`** - File này

## Cách sử dụng

### Phương pháp 1: Sử dụng PowerShell (Khuyến nghị)
```powershell
# Build installer cơ bản
.\build_installer.ps1

# Build installer nâng cao
.\build_installer.ps1 -Advanced

# Xem hướng dẫn
.\build_installer.ps1 -Help
```

### Phương pháp 2: Sử dụng Batch
```cmd
# Build installer cơ bản
build_installer.bat
```

### Phương pháp 3: Thủ công
1. Build ứng dụng Flutter: `flutter build windows --release`
2. Mở file `installer.iss` trong Inno Setup IDE
3. Nhấn F9 để compile

## Tính năng của installer

### Installer cơ bản (`installer.iss`)
- ✅ Cài đặt ứng dụng
- ✅ Tạo shortcut trong Start Menu
- ✅ Tạo shortcut trên Desktop (tùy chọn)
- ✅ Hỗ trợ gỡ cài đặt
- ✅ Hỗ trợ tiếng Việt
- ✅ Chạy ứng dụng sau khi cài đặt

### Installer nâng cao (`installer_advanced.iss`)
- ✅ Tất cả tính năng của installer cơ bản
- ✅ Tùy chọn khởi động cùng Windows
- ✅ Giao diện wizard tùy chỉnh
- ✅ Xóa file tạm khi gỡ cài đặt
- ✅ Kiểm tra phiên bản Windows (Windows 10+)
- ✅ Chỉ hỗ trợ x64
- ✅ Logging chi tiết

## Cấu trúc thư mục sau khi build

```
Tremowaves/
├── build/
│   └── windows/
│       └── x64/
│           └── runner/
│               └── Release/
│                   ├── auto_saver.exe
│                   └── [các file khác]
├── installer/
│   └── TremoSave_Setup.exe  # File installer cuối cùng
├── installer.iss
├── installer_advanced.iss
├── build_installer.bat
├── build_installer.ps1
└── README_INSTALLER.md
```

## Yêu cầu hệ thống

### Để build installer
- Windows 10 trở lên
- Flutter SDK
- Inno Setup (tùy chọn, để build tự động)

### Để chạy installer
- Windows 10 trở lên
- Không yêu cầu quyền Administrator

## Troubleshooting

### Lỗi thường gặp

1. **"Flutter not found"**
   - Cài đặt Flutter SDK
   - Thêm Flutter vào PATH

2. **"Inno Setup not found"**
   - Tải Inno Setup từ: https://jrsoftware.org/isinfo.php
   - Thêm ISCC vào PATH

3. **"Build failed"**
   - Kiểm tra lỗi trong console
   - Đảm bảo tất cả dependencies đã được cài đặt

4. **"Permission denied"**
   - Chạy với quyền Administrator
   - Hoặc thay đổi `PrivilegesRequired=admin` trong script

## Liên kết hữu ích

- [Inno Setup Documentation](https://jrsoftware.org/ishelp/)
- [Flutter Windows Deployment](https://docs.flutter.dev/deployment/windows)
- [Inno Setup Download](https://jrsoftware.org/isinfo.php) 