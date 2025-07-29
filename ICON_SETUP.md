# Hướng dẫn thiết lập Icon cho Tremo Save

## Yêu cầu Icon

Để sử dụng icon tùy chỉnh cho installer, bạn cần:

1. **File icon**: `AppIcon.png` (đã được cung cấp)
2. **Định dạng**: Chuyển đổi từ PNG sang ICO
3. **Kích thước**: 256x256 pixels (khuyến nghị)

## Cách chuyển đổi PNG sang ICO

### Phương pháp 1: Sử dụng công cụ online
1. Truy cập: https://convertio.co/png-ico/
2. Upload file `AppIcon.png`
3. Tải file `AppIcon.ico` về
4. Đặt file vào thư mục `assets/`

### Phương pháp 2: Sử dụng Photoshop/GIMP
1. Mở file `AppIcon.png`
2. Export/Save As với định dạng ICO
3. Đặt file vào thư mục `assets/`

### Phương pháp 3: Sử dụng PowerShell (Windows)
```powershell
# Cài đặt module ImageMagick (nếu chưa có)
# Install-Module -Name ImageMagick

# Chuyển đổi PNG sang ICO
magick convert AppIcon.png -resize 256x256 assets\AppIcon.ico
```

## Cấu trúc thư mục

```
TremoSave/
├── assets/
│   └── AppIcon.ico          # Icon cho installer
├── installer.iss            # Script installer cơ bản
├── installer_advanced.iss   # Script installer nâng cao
└── [các file khác]
```

## Kiểm tra icon

Sau khi đặt file `AppIcon.ico` vào thư mục `assets/`, bạn có thể:

1. **Build installer**: `.\build_installer.ps1`
2. **Kiểm tra**: Mở file installer và xem icon trong Properties

## Troubleshooting

### Lỗi "Icon not found"
- Đảm bảo file `AppIcon.ico` tồn tại trong thư mục `assets/`
- Kiểm tra đường dẫn trong file `installer.iss`

### Icon không hiển thị đúng
- Đảm bảo file ICO có kích thước 256x256 pixels
- Thử chuyển đổi lại với công cụ khác

### Icon quá lớn/nhỏ
- Điều chỉnh kích thước icon về 256x256 pixels
- Sử dụng công cụ chỉnh sửa ảnh để tối ưu

## Thông tin Icon hiện tại

- **Tên**: Tremo Save Icon
- **Màu chủ đạo**: Xanh lá cây đậm
- **Ký tự**: "SV" (Save)
- **Thiết kế**: Hiện đại, 3D, chuyên nghiệp 