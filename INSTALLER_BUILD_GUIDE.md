# TremoSave Installer Build Guide

## Prerequisites

### 1. Install Inno Setup
Download and install Inno Setup from: https://jrsoftware.org/isinfo.php

After installation, make sure `iscc.exe` is in your system PATH.

### 2. Flutter Development Environment
Ensure you have Flutter SDK installed and configured for Windows development.

## Build Options

### Option 1: Using PowerShell Script (Recommended)
```powershell
.\build_installer.ps1
```

### Option 2: Using Batch File
```cmd
.\build_installer.bat
```

### Option 3: Manual Build
1. Build Flutter app:
   ```bash
   flutter build windows --release
   ```

2. Build basic installer:
   ```bash
   iscc installer.iss
   ```

3. Build advanced installer:
   ```bash
   iscc installer_advanced.iss
   ```

## Installer Types

### Basic Installer (`installer.iss`)
- Simple installation
- Creates desktop and start menu shortcuts
- Option to launch after installation
- **Output**: `installer\TremoSave_Setup.exe`

### Advanced Installer (`installer_advanced.iss`)
- Enhanced installation with welcome page
- Startup integration option
- Registry modifications for auto-start
- Clean uninstallation with log cleanup
- **Output**: `installer\TremoSave_Setup_v1.0.0.exe`

## Installer Features

### ✅ Included Features
- **Modern UI**: Uses modern wizard style
- **Desktop Shortcut**: Optional desktop icon creation
- **Start Menu**: Creates program group in Start Menu
- **Auto-start Option**: Can configure to start with Windows
- **Clean Uninstall**: Removes all files and registry entries
- **Multi-language**: English language support
- **Icon Integration**: Uses app icon throughout installer

### 🔧 Configuration Options
- **App Name**: Tremo Save
- **Version**: 1.0.0
- **Publisher**: Tremowaves
- **Website**: https://tremowaves.com
- **Architecture**: x64 only
- **Windows Version**: Windows 10+ required

## Troubleshooting

### Common Issues

#### 1. "iscc not found"
**Solution**: Install Inno Setup and ensure it's in PATH

#### 2. "Flutter build failed"
**Solution**: 
- Check Flutter installation: `flutter doctor`
- Clean build: `flutter clean`
- Rebuild: `flutter build windows --release`

#### 3. "File not found: TremoSave.exe"
**Solution**: 
- Ensure Flutter build completed successfully
- Check that `build\windows\x64\runner\Release\TremoSave.exe` exists

#### 4. "Permission denied"
**Solution**: 
- Run as Administrator if needed
- Check antivirus software isn't blocking the build

## Customization

### Modifying Installer Configuration

#### Update App Information
Edit `installer.iss` or `installer_advanced.iss`:
```ini
AppName=Tremo Save
AppVersion=1.0.0
AppPublisher=Your Company Name
AppPublisherURL=https://your-website.com
```

#### Change Installer Options
```ini
; Require admin privileges
PrivilegesRequired=admin

; Add license file
LicenseFile=LICENSE.txt

; Add custom welcome/info pages
InfoBeforeFile=WELCOME.txt
InfoAfterFile=README.txt
```

#### Add Additional Files
```ini
[Files]
Source: "build\windows\x64\runner\Release\TremoSave.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs
Source: "LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
```

## Distribution

### Recommended Files for Distribution
1. **Basic Installer**: `installer\TremoSave_Setup.exe`
2. **Advanced Installer**: `installer\TremoSave_Setup_v1.0.0.exe`
3. **App Icon**: `assets\AppIcon.ico`
4. **README**: Include installation instructions

### File Sizes
- Basic installer: ~50-100 MB
- Advanced installer: ~50-100 MB
- Depends on Flutter app size and included assets

## Version Management

### Updating Version
1. Update `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```

2. Update installer files:
   ```ini
   AppVersion=1.0.1
   OutputBaseFilename=TremoSave_Setup_v1.0.1
   ```

3. Rebuild:
   ```bash
   flutter build windows --release
   iscc installer_advanced.iss
   ```

## Security Considerations

### Code Signing (Recommended for Distribution)
For production distribution, consider code signing your installer:
1. Obtain a code signing certificate
2. Use `signtool.exe` to sign the installer
3. This prevents Windows SmartScreen warnings

### Antivirus Compatibility
- Test installer with common antivirus software
- Consider submitting to antivirus vendors for whitelisting
- Use code signing to improve trust

## Support

For issues with the installer build process:
1. Check Flutter build logs
2. Verify Inno Setup installation
3. Test with clean build environment
4. Review Windows Event Viewer for system errors 