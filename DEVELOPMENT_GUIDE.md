# TremoSave Development Environment Guide

## 🚀 Environment Setup

### Prerequisites
- Flutter SDK (3.32.6+)
- Visual Studio 2022 with "Desktop development with C++" workload
- Windows 10 SDK (10.0.26100.0+)
- Android Studio (optional, for Android development)

### Quick Setup
```powershell
# Run the development setup script
.\dev_scripts.ps1 setup
```

### Manual Setup Steps

1. **Enable Windows Desktop Support**
   ```bash
   flutter config --enable-windows-desktop
   ```

2. **Accept Android Licenses**
   ```bash
   flutter doctor --android-licenses
   ```

3. **Verify Environment**
   ```bash
   flutter doctor -v
   ```

## 🛠️ Development Scripts

Sử dụng script `dev_scripts.ps1` để quản lý development workflow:

```powershell
# Show help
.\dev_scripts.ps1 help

# Run static analysis
.\dev_scripts.ps1 analyze

# Clean build cache
.\dev_scripts.ps1 clean

# Build for Windows
.\dev_scripts.ps1 build

# Auto-fix common issues
.\dev_scripts.ps1 fix
```

## 📊 Code Quality Management

### Static Analysis
```bash
# Run analysis with detailed output
flutter analyze --no-congratulate

# Filter top issues
flutter analyze --no-congratulate | Select-String "(error|warning)" | Select-Object -First 20
```

### Code Formatting
```bash
# Format all Dart files
dart format lib/

# Format specific file
dart format lib/main.dart
```

### Dependency Analysis
```bash
# Analyze dependency tree
flutter pub deps

# Check for outdated packages
flutter pub outdated
```

## 🔧 Troubleshooting

### CMake Issues
Khi gặp lỗi CMake, thực hiện clean build:
```bash
flutter clean
Remove-Item -Path "build" -Recurse -Force
flutter pub get
flutter build windows
```

### Visual Studio Issues
- Đảm bảo cài đặt "Desktop development with C++" workload
- Kiểm tra Windows 10 SDK version
- Restart IDE sau khi cài đặt components mới

### Plugin Development
```bash
# Tạo plugin với FFI support
flutter create --template plugin_ffi my_plugin

# Bundle DLLs properly trong CMakeLists.txt
```

## 📁 Project Structure

```
TremoSave/
├── lib/                    # Main Dart code
│   ├── models/            # Data models
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   └── widgets/           # Reusable widgets
├── windows/               # Windows-specific code
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── assets/                # Static assets
├── test/                  # Unit tests
├── analysis_options.yaml  # Linter configuration
├── dev_scripts.ps1       # Development scripts
└── pubspec.yaml          # Dependencies
```

## 🎯 Best Practices

### Code Quality
- Sử dụng `const` constructors khi có thể
- Tránh `print()` statements trong production code
- Sử dụng proper error handling
- Implement proper resource cleanup

### Performance
- Minimize widget rebuilds
- Use `const` widgets for static content
- Implement proper state management
- Optimize image loading and caching

### Security
- Validate all user inputs
- Implement proper authentication
- Use secure storage for sensitive data
- Follow Windows security guidelines

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.6'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build windows
```

## 📚 Additional Resources

- [Flutter Windows Desktop](https://docs.flutter.dev/desktop)
- [Dart Analysis Options](https://dart.dev/guides/language/analysis-options)
- [Flutter Lints](https://dart.dev/tools/linter-rules)
- [Windows Development](https://docs.microsoft.com/en-us/windows/apps/)

## 🆘 Common Issues & Solutions

### Issue: "Cannot find Chrome executable"
**Solution**: Install Chrome hoặc set `CHROME_EXECUTABLE` environment variable

### Issue: "Android licenses not accepted"
**Solution**: Run `flutter doctor --android-licenses` và accept all licenses

### Issue: "CMake configuration failed"
**Solution**: 
1. Clean build cache: `flutter clean`
2. Reinstall Visual Studio components
3. Verify Windows SDK installation

### Issue: "Plugin not found"
**Solution**: 
1. Run `flutter pub get`
2. Check `pubspec.yaml` dependencies
3. Verify plugin compatibility

## 📈 Performance Monitoring

### Memory Usage
```bash
# Monitor memory usage during development
flutter run --profile
```

### Build Performance
```bash
# Measure build time
Measure-Command { flutter build windows }
```

### Code Metrics
```bash
# Analyze code complexity
dart analyze --fatal-infos
```

---

**Lưu ý**: Luôn cập nhật Flutter SDK và dependencies để đảm bảo security và performance tối ưu. 