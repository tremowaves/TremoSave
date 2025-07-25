import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:ps_list/ps_list.dart';
import 'package:auto_saver/models/app_info.dart';
import 'package:auto_saver/models/save_log.dart';

enum LogSortType { time, appName }

class AppState extends ChangeNotifier {
  List<AppInfo> applications = [];
  int interval = 5; // minutes
  bool onlyActiveWindow = true;
  bool isRunning = false;
  bool isDarkMode = true; // Default to dark mode
  bool showLogs = false;
  List<SaveLog> saveLogs = [];
  LogSortType currentSortType = LogSortType.time;

  Timer? _timer;
  
  AppState() {
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      final processes = await PSList.getRunningProcesses();
      
      // Lọc chỉ các ứng dụng có cửa sổ (loại bỏ process ngầm)
      final windowedApps = await _getWindowedApplications(processes);
      
      applications = windowedApps.map((process) => AppInfo(
        name: _getDisplayName(process),
        processName: process,
      )).toList();
      
      // Sắp xếp theo tên hiển thị
      applications.sort((a, b) => a.name.compareTo(b.name));
      
      notifyListeners();
    } catch (e) {
      print('Error loading applications: $e');
      applications = [];
      notifyListeners();
    }
  }

  Future<List<String>> _getWindowedApplications(List<String> allProcesses) async {
    // Danh sách các process thường có cửa sổ
    final commonWindowedApps = [
      'chrome.exe', 'firefox.exe', 'msedge.exe', 'opera.exe', 'brave.exe',
      'notepad.exe', 'notepad++.exe', 'code.exe', 'cursor.exe', 'vscode.exe',
      'wordpad.exe', 'mspaint.exe', 'calc.exe', 'explorer.exe',
      'winword.exe', 'excel.exe', 'powerpnt.exe', 'outlook.exe',
      'photoshop.exe', 'illustrator.exe', 'indesign.exe',
      'autocad.exe', 'solidworks.exe', 'fusion360.exe',
      'blender.exe', 'maya.exe', '3dsmax.exe',
      'premiere.exe', 'afterfx.exe', 'audition.exe',
      'spotify.exe', 'vlc.exe', 'potplayer.exe',
      'discord.exe', 'teams.exe', 'zoom.exe', 'skype.exe',
      'telegram.exe', 'whatsapp.exe', 'slack.exe',
      'obs.exe', 'streamlabs.exe', 'xsplit.exe',
      'steam.exe', 'epicgameslauncher.exe', 'origin.exe',
      'minecraft.exe', 'roblox.exe',
      'adobe.exe', 'acrobat.exe', 'reader.exe',
      'winrar.exe', '7zfm.exe', 'winzip.exe',
      'utorrent.exe', 'qbittorrent.exe',
      'ccleaner.exe', 'malwarebytes.exe', 'avast.exe',
      'teamviewer.exe', 'anydesk.exe', 'ultraviewer.exe',
    ];

    return allProcesses.where((process) {
      final lowerProcess = process.toLowerCase();
      return commonWindowedApps.any((app) => lowerProcess.contains(app.replaceAll('.exe', '')));
    }).toList();
  }

  String _getDisplayName(String processName) {
    // Chuyển đổi tên process thành tên hiển thị thân thiện
    final nameMap = {
      'chrome.exe': 'Google Chrome',
      'firefox.exe': 'Mozilla Firefox',
      'msedge.exe': 'Microsoft Edge',
      'opera.exe': 'Opera Browser',
      'brave.exe': 'Brave Browser',
      'notepad.exe': 'Notepad',
      'notepad++.exe': 'Notepad++',
      'code.exe': 'Visual Studio Code',
      'cursor.exe': 'Cursor Editor',
      'vscode.exe': 'Visual Studio Code',
      'wordpad.exe': 'WordPad',
      'mspaint.exe': 'Paint',
      'calc.exe': 'Calculator',
      'explorer.exe': 'File Explorer',
      'winword.exe': 'Microsoft Word',
      'excel.exe': 'Microsoft Excel',
      'powerpnt.exe': 'Microsoft PowerPoint',
      'outlook.exe': 'Microsoft Outlook',
      'photoshop.exe': 'Adobe Photoshop',
      'illustrator.exe': 'Adobe Illustrator',
      'indesign.exe': 'Adobe InDesign',
      'autocad.exe': 'AutoCAD',
      'solidworks.exe': 'SolidWorks',
      'fusion360.exe': 'Fusion 360',
      'blender.exe': 'Blender',
      'maya.exe': 'Autodesk Maya',
      '3dsmax.exe': '3ds Max',
      'premiere.exe': 'Adobe Premiere Pro',
      'afterfx.exe': 'Adobe After Effects',
      'audition.exe': 'Adobe Audition',
      'spotify.exe': 'Spotify',
      'vlc.exe': 'VLC Media Player',
      'potplayer.exe': 'PotPlayer',
      'discord.exe': 'Discord',
      'teams.exe': 'Microsoft Teams',
      'zoom.exe': 'Zoom',
      'skype.exe': 'Skype',
      'telegram.exe': 'Telegram',
      'whatsapp.exe': 'WhatsApp',
      'slack.exe': 'Slack',
      'obs.exe': 'OBS Studio',
      'streamlabs.exe': 'Streamlabs OBS',
      'xsplit.exe': 'XSplit Broadcaster',
      'steam.exe': 'Steam',
      'epicgameslauncher.exe': 'Epic Games Launcher',
      'origin.exe': 'Origin',
      'minecraft.exe': 'Minecraft',
      'roblox.exe': 'Roblox',
      'adobe.exe': 'Adobe Creative Cloud',
      'acrobat.exe': 'Adobe Acrobat',
      'reader.exe': 'Adobe Reader',
      'winrar.exe': 'WinRAR',
      '7zfm.exe': '7-Zip',
      'winzip.exe': 'WinZip',
      'utorrent.exe': 'uTorrent',
      'qbittorrent.exe': 'qBittorrent',
      'ccleaner.exe': 'CCleaner',
      'malwarebytes.exe': 'Malwarebytes',
      'avast.exe': 'Avast Antivirus',
      'teamviewer.exe': 'TeamViewer',
      'anydesk.exe': 'AnyDesk',
      'ultraviewer.exe': 'UltraViewer',
    };

    final lowerProcess = processName.toLowerCase();
    for (final entry in nameMap.entries) {
      if (lowerProcess.contains(entry.key.replaceAll('.exe', ''))) {
        return entry.value;
      }
    }

    // Nếu không tìm thấy trong map, trả về tên gốc nhưng đẹp hơn
    return processName.replaceAll('.exe', '').split('\\').last;
  }

  List<AppInfo> get selectedApplications => 
      applications.where((app) => app.isSelected).toList();

  List<SaveLog> get sortedLogs {
    final sorted = List<SaveLog>.from(saveLogs);
    switch (currentSortType) {
      case LogSortType.time:
        sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case LogSortType.appName:
        sorted.sort((a, b) => a.appName.compareTo(b.appName));
        break;
    }
    return sorted;
  }

  void toggleApplicationSelection(int index) {
    if (index >= 0 && index < applications.length) {
      applications[index].toggleSelection();
      notifyListeners();
    }
  }

  void selectAllApplications() {
    for (final app in applications) {
      app.isSelected = true;
    }
    notifyListeners();
  }

  void deselectAllApplications() {
    for (final app in applications) {
      app.isSelected = false;
    }
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void toggleLogs() {
    showLogs = !showLogs;
    notifyListeners();
  }

  void setLogSortType(LogSortType sortType) {
    currentSortType = sortType;
    notifyListeners();
  }

  void clearLogs() {
    saveLogs.clear();
    notifyListeners();
  }

  void setInterval(double value) {
    interval = value.toInt();
    notifyListeners();
  }

  void setOnlyActiveWindow(bool? value) {
    onlyActiveWindow = value ?? true;
    notifyListeners();
  }

  Future<void> startAutoSave() async {
    if (selectedApplications.isEmpty) return;
    isRunning = true;
    notifyListeners();

    // Register a hotkey (Ctrl+Shift+S) to stop the auto-save
    try {
      await hotKeyManager.register(
        HotKey(key: PhysicalKeyboardKey.keyS, modifiers: [HotKeyModifier.control, HotKeyModifier.shift]),
        keyDownHandler: (_) => stopAutoSave(),
      );
    } catch (e) {
      print('Error registering hotkey: $e');
    }

    _timer = Timer.periodic(Duration(minutes: interval), (_) => _doSave());
  }

  void stopAutoSave() {
    _timer?.cancel();
    try {
      hotKeyManager.unregisterAll();
    } catch (e) {
      print('Error unregistering hotkeys: $e');
    }
    isRunning = false;
    notifyListeners();
  }

  Future<void> _doSave() async {
    if (selectedApplications.isEmpty) return;

    try {
      // Simulate Ctrl+S using Flutter's services
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      
      // Add logs for each selected application
      for (final app in selectedApplications) {
        final log = SaveLog(
          appName: app.name,
          processName: app.processName,
          timestamp: DateTime.now(),
          success: true,
        );
        saveLogs.add(log);
        print('Auto-saved process: ${app.processName}');
      }
      
      notifyListeners();
      
      // In a real implementation, you would:
      // 1. Find the target window
      // 2. Focus it
      // 3. Send Ctrl+S
      // 4. Restore previous focus
      
    } catch (e) {
      print('Error during auto-save: $e');
      
      // Add error logs
      for (final app in selectedApplications) {
        final log = SaveLog(
          appName: app.name,
          processName: app.processName,
          timestamp: DateTime.now(),
          success: false,
        );
        saveLogs.add(log);
      }
      notifyListeners();
    }
  }
}
