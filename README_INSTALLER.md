# Hướng dẫn tạo Installer cho Tremo Save

## Yêu cầu

1. **Inno Setup**: Tải và cài đặt Inno Setup từ [trang chủ chính thức](https://jrsoftware.org/isinfo.php)
2. **Flutter SDK**: Đã được cài đặt và cấu hình

## Các bước thực hiện

### 1. Build ứng dụng Flutter
```bash
flutter build windows --release
```

### 2. Tạo installer bằng Inno Setup

#### Cách 1: Sử dụng Inno Setup Compiler (Command Line)
```bash
# Cài đặt Inno Setup Compiler (ISCC) vào PATH
# Sau đó chạy lệnh:
iscc installer.iss
```

#### Cách 2: Sử dụng Inno Setup IDE
1. Mở Inno Setup IDE
2. Mở file `installer.iss`
3. Nhấn F9 hoặc chọn Build > Compile

### 3. Kết quả
File installer sẽ được tạo tại: `installer/AutoSaver_Setup.exe`

## Cấu hình file installer.iss

### Thông tin cơ bản
- **AppName**: Tên ứng dụng hiển thị
- **AppVersion**: Phiên bản ứng dụng
- **AppPublisher**: Tên nhà phát triển
- **DefaultDirName**: Thư mục cài đặt mặc định
- **OutputBaseFilename**: Tên file installer

### Tùy chỉnh
Bạn có thể chỉnh sửa các thông tin sau trong file `installer.iss`:

```ini
AppName=Tremo Save
AppVersion=1.0.0
AppPublisher=Tremowaves
AppPublisherURL=https://tremowaves.com
```

### Thêm file license hoặc thông tin
```ini
LicenseFile=LICENSE.txt
InfoBeforeFile=README.txt
InfoAfterFile=CHANGELOG.txt
```

### Icon tùy chỉnh
Icon mặc định được đặt tại `assets\AppIcon.ico`. Bạn có thể thay thế file này bằng icon của riêng mình.

## Tính năng installer

- ✅ Cài đặt tự động
- ✅ Tạo shortcut trên Desktop (tùy chọn)
- ✅ Tạo shortcut trong Start Menu
- ✅ Hỗ trợ gỡ cài đặt
- ✅ Hỗ trợ tiếng Việt
- ✅ Chạy ứng dụng sau khi cài đặt (tùy chọn)

## Troubleshooting

### Lỗi "File not found"
- Đảm bảo đã build ứng dụng Flutter thành công
- Kiểm tra đường dẫn trong section [Files]

### Lỗi "Permission denied"
- Chạy Inno Setup với quyền Administrator
- Hoặc thay đổi `PrivilegesRequired=lowest` thành `PrivilegesRequired=admin`

### Lỗi "Icon not found"
- Kiểm tra file icon tại `windows\runner\resources\app_icon.ico`
- Hoặc xóa dòng `SetupIconFile` nếu không có icon

## Liên kết hữu ích

- [Inno Setup Documentation](https://jrsoftware.org/ishelp/)
- [Inno Setup Examples](https://jrsoftware.org/isinfo.php)
- [Flutter Windows Deployment](https://docs.flutter.dev/deployment/windows) 