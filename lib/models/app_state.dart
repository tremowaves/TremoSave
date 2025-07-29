import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:ps_list/ps_list.dart';
import 'package:auto_saver/models/app_info.dart';
import 'package:auto_saver/models/save_log.dart';
import 'package:auto_saver/models/app_settings.dart';
import 'package:auto_saver/services/tray_service.dart';
import 'package:auto_saver/services/auto_start_service.dart';
import 'package:auto_saver/services/keyboard_service.dart';

enum LogSortType { time, appName }

class AppState extends ChangeNotifier {
  List<AppInfo> applications = [];
  int interval = 5; // minutes
  bool isRunning = false;
  bool isDarkMode = true; // Default to dark mode
  bool showLogs = false;
  List<SaveLog> saveLogs = [];
  LogSortType currentSortType = LogSortType.time;
  
  // Settings mới
  bool autoRun = false;
  bool minimizeToTray = false;
  bool showNotifications = true;
  bool useWindowsNotification = true;

  Timer? _timer;
  
  AppState() {
    loadApplications();
    loadSettings();
  }

  Future<void> loadApplications() async {
    try {
      final processes = await PSList.getRunningProcesses();
      
      print('Found ${processes.length} total processes');
      
      // Lọc chỉ các ứng dụng có cửa sổ (loại bỏ process ngầm)
      final windowedApps = await _getWindowedApplications(processes);
      
      print('Found ${windowedApps.length} windowed applications:');
      for (final app in windowedApps) {
        print('  - $app');
      }
      
      // Tạo map để nhóm các ứng dụng trùng lặp
      final Map<String, List<String>> groupedApps = {};
      
      for (final process in windowedApps) {
        // Lọc bỏ các process phụ
        if (process.contains('_osc_action_') || 
            process.contains('webhelper') ||
            process.contains('service') ||
            process.contains('helper')) {
          continue;
        }
        
        final displayName = _getDisplayName(process);
        if (displayName != null) {
          if (groupedApps.containsKey(displayName)) {
            groupedApps[displayName]!.add(process);
          } else {
            groupedApps[displayName] = [process];
          }
        }
      }
      
      print('Grouped into ${groupedApps.length} applications:');
      for (final entry in groupedApps.entries) {
        print('  - ${entry.key}: ${entry.value.join(', ')}');
      }
      
      // Tạo danh sách ứng dụng đã nhóm
      applications = groupedApps.entries.map((entry) {
        final processNames = entry.value.join(', ');
        return AppInfo(
          name: entry.key,
          processName: processNames,
        );
      }).toList();
      
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
      // Thêm Reaper và các ứng dụng audio khác (chỉ process chính)
      'reaper.exe', 'reaper64.exe', 'reaper32.exe',
      'audacity.exe', 'flstudio.exe', 'ableton.exe', 'protools.exe',
      'cubase.exe', 'logic.exe', 'garageband.exe',
      'cakewalk.exe', 'sonar.exe', 'studioone.exe',
      'bitwig.exe', 'reason.exe', 'live.exe',
      
      // 2D Graphics & Design
      'photoshop.exe', 'illustrator.exe', 'indesign.exe', 'xd.exe', 'figma.exe',
      'sketch.exe', 'affinitydesigner.exe', 'affinityphoto.exe', 'affinitypublisher.exe',
      'gimp.exe', 'inkscape.exe', 'krita.exe', 'paint.net.exe', 'paint.exe',
      'coreldraw.exe', 'xara.exe', 'serif.exe', 'canva.exe',
      
      // 3D Modeling & Animation
      'blender.exe', 'maya.exe', '3dsmax.exe', 'cinema4d.exe', 'houdini.exe',
      'zbrush.exe', 'mudbox.exe', 'sketchup.exe', 'rhino.exe', 'fusion360.exe',
      'solidworks.exe', 'autocad.exe', 'revit.exe', 'archicad.exe', 'vectorworks.exe',
      'lightwave.exe', 'modo.exe', 'carrara.exe', 'daz3d.exe', 'poser.exe',
      'vray.exe', 'corona.exe', 'arnold.exe', 'redshift.exe', 'octane.exe',
      
      // Video Editing & VFX
      'premiere.exe', 'afterfx.exe', 'audition.exe', 'mediaencoder.exe',
      'davinci.exe', 'resolve.exe', 'finalcut.exe', 'vegas.exe', 'edius.exe',
      'avid.exe', 'mediacomposer.exe', 'nuke.exe', 'fusion.exe', 'flame.exe',
      'motion.exe', 'compressor.exe', 'color.exe', 'cinema.exe',
      'hitfilm.exe', 'camtasia.exe', 'obs.exe', 'streamlabs.exe', 'xsplit.exe',
      
      // Game Engines & Development
      'unity.exe', 'unreal.exe', 'godot.exe', 'gamemaker.exe', 'construct.exe',
      'rpgmaker.exe', 'renpy.exe', 'twine.exe', 'scratch.exe', 'stencyl.exe',
      'cocos2d.exe', 'corona.exe', 'love.exe', 'sfml.exe', 'sdl.exe',
      'monogame.exe', 'xna.exe', 'cryengine.exe', 'source.exe', 'idtech.exe',
      
      // Programming & Development
      'code.exe', 'cursor.exe', 'vscode.exe', 'sublime.exe', 'atom.exe',
      'notepad++.exe', 'brackets.exe', 'webstorm.exe', 'intellij.exe', 'eclipse.exe',
      'netbeans.exe', 'visualstudio.exe', 'vs.exe', 'devcpp.exe', 'codeblocks.exe',
      'qtcreator.exe', 'androidstudio.exe', 'xcode.exe', 'xampp.exe', 'wamp.exe',
      'node.exe', 'python.exe', 'java.exe', 'javac.exe', 'gcc.exe', 'cl.exe',
      
      // Office & Productivity
      'winword.exe', 'excel.exe', 'powerpnt.exe', 'outlook.exe', 'access.exe',
      'publisher.exe', 'onenote.exe', 'teams.exe', 'skype.exe', 'lync.exe',
      'libreoffice.exe', 'openoffice.exe', 'wps.exe', 'kingsoft.exe',
      'googlechrome.exe', 'chrome.exe', 'firefox.exe', 'msedge.exe', 'opera.exe',
      'brave.exe', 'safari.exe', 'vivaldi.exe', 'tor.exe',
      
      // File Management & Utilities
      'explorer.exe', 'totalcommander.exe', 'freecommander.exe', 'xyplorer.exe',
      'winrar.exe', '7zfm.exe', 'winzip.exe', 'peazip.exe', 'bandizip.exe',
      'utorrent.exe', 'qbittorrent.exe', 'transmission.exe', 'deluge.exe',
      'ccleaner.exe', 'malwarebytes.exe', 'avast.exe', 'norton.exe', 'mcafee.exe',
      'teamviewer.exe', 'anydesk.exe', 'ultraviewer.exe', 'logmein.exe',
      
      // Creative & Media
      'spotify.exe', 'vlc.exe', 'potplayer.exe', 'mpc.exe', 'kodi.exe',
      'itunes.exe', 'windowsmediaplayer.exe', 'wmp.exe', 'quicktime.exe',
      'discord.exe', 'telegram.exe', 'whatsapp.exe', 'slack.exe', 'zoom.exe',
      'skype.exe', 'teams.exe', 'webex.exe', 'gotomeeting.exe',
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
      
      // Audio applications
      'reaper.exe': 'REAPER',
      'reaper64.exe': 'REAPER (64-bit)',
      'reaper32.exe': 'REAPER (32-bit)',
      'audacity.exe': 'Audacity',
      'flstudio.exe': 'FL Studio',
      'ableton.exe': 'Ableton Live',
      'protools.exe': 'Pro Tools',
      'cubase.exe': 'Cubase',
      'logic.exe': 'Logic Pro',
      'garageband.exe': 'GarageBand',
      'cakewalk.exe': 'Cakewalk',
      'sonar.exe': 'Cakewalk Sonar',
      'studioone.exe': 'Studio One',
      'bitwig.exe': 'Bitwig Studio',
      'reason.exe': 'Reason',
      'live.exe': 'Ableton Live',
      
      // 2D Graphics & Design
      'photoshop.exe': 'Adobe Photoshop',
      'illustrator.exe': 'Adobe Illustrator',
      'indesign.exe': 'Adobe InDesign',
      'xd.exe': 'Adobe XD',
      'figma.exe': 'Figma',
      'sketch.exe': 'Sketch',
      'affinitydesigner.exe': 'Affinity Designer',
      'affinityphoto.exe': 'Affinity Photo',
      'affinitypublisher.exe': 'Affinity Publisher',
      'gimp.exe': 'GIMP',
      'inkscape.exe': 'Inkscape',
      'krita.exe': 'Krita',
      'paint.net.exe': 'Paint.NET',
      'paint.exe': 'Paint',
      'coreldraw.exe': 'CorelDRAW',
      'xara.exe': 'Xara Designer',
      'serif.exe': 'Serif Affinity',
      'canva.exe': 'Canva',
      
      // 3D Modeling & Animation
      'blender.exe': 'Blender',
      'maya.exe': 'Autodesk Maya',
      '3dsmax.exe': '3ds Max',
      'cinema4d.exe': 'Cinema 4D',
      'houdini.exe': 'Houdini',
      'zbrush.exe': 'ZBrush',
      'mudbox.exe': 'Autodesk Mudbox',
      'sketchup.exe': 'SketchUp',
      'rhino.exe': 'Rhino 3D',
      'fusion360.exe': 'Fusion 360',
      'solidworks.exe': 'SolidWorks',
      'autocad.exe': 'AutoCAD',
      'revit.exe': 'Autodesk Revit',
      'archicad.exe': 'ArchiCAD',
      'vectorworks.exe': 'Vectorworks',
      'lightwave.exe': 'LightWave 3D',
      'modo.exe': 'Modo',
      'carrara.exe': 'Carrara',
      'daz3d.exe': 'DAZ 3D Studio',
      'poser.exe': 'Poser',
      'vray.exe': 'V-Ray',
      'corona.exe': 'Corona Renderer',
      'arnold.exe': 'Arnold Renderer',
      'redshift.exe': 'Redshift',
      'octane.exe': 'Octane Render',
      
      // Video Editing & VFX
      'premiere.exe': 'Adobe Premiere Pro',
      'afterfx.exe': 'Adobe After Effects',
      'audition.exe': 'Adobe Audition',
      'mediaencoder.exe': 'Adobe Media Encoder',
      'davinci.exe': 'DaVinci Resolve',
      'resolve.exe': 'DaVinci Resolve',
      'finalcut.exe': 'Final Cut Pro',
      'vegas.exe': 'Vegas Pro',
      'edius.exe': 'EDIUS',
      'avid.exe': 'Avid Media Composer',
      'mediacomposer.exe': 'Avid Media Composer',
      'nuke.exe': 'Nuke',
      'fusion.exe': 'Blackmagic Fusion',
      'flame.exe': 'Autodesk Flame',
      'motion.exe': 'Motion',
      'compressor.exe': 'Compressor',
      'color.exe': 'DaVinci Resolve Color',
      'cinema.exe': 'Cinema 4D',
      'hitfilm.exe': 'HitFilm',
      'camtasia.exe': 'Camtasia',
      'obs.exe': 'OBS Studio',
      'streamlabs.exe': 'Streamlabs OBS',
      'xsplit.exe': 'XSplit Broadcaster',
      
      // Game Engines & Development
      'unity.exe': 'Unity',
      'unreal.exe': 'Unreal Engine',
      'godot.exe': 'Godot Engine',
      'gamemaker.exe': 'GameMaker Studio',
      'construct.exe': 'Construct',
      'rpgmaker.exe': 'RPG Maker',
      'renpy.exe': 'Ren\'Py',
      'twine.exe': 'Twine',
      'scratch.exe': 'Scratch',
      'stencyl.exe': 'Stencyl',
      'cocos2d.exe': 'Cocos2d',
      'love.exe': 'LÖVE',
      'sfml.exe': 'SFML',
      'sdl.exe': 'SDL',
      'monogame.exe': 'MonoGame',
      'xna.exe': 'XNA Framework',
      'cryengine.exe': 'CryEngine',
      'source.exe': 'Source Engine',
      'idtech.exe': 'id Tech Engine',
      
      // Programming & Development
      'code.exe': 'Visual Studio Code',
      'cursor.exe': 'Cursor Editor',
      'vscode.exe': 'Visual Studio Code',
      'sublime.exe': 'Sublime Text',
      'atom.exe': 'Atom',
      'notepad++.exe': 'Notepad++',
      'brackets.exe': 'Brackets',
      'webstorm.exe': 'WebStorm',
      'intellij.exe': 'IntelliJ IDEA',
      'eclipse.exe': 'Eclipse',
      'netbeans.exe': 'NetBeans',
      'visualstudio.exe': 'Visual Studio',
      'vs.exe': 'Visual Studio',
      'devcpp.exe': 'Dev-C++',
      'codeblocks.exe': 'Code::Blocks',
      'qtcreator.exe': 'Qt Creator',
      'androidstudio.exe': 'Android Studio',
      'xcode.exe': 'Xcode',
      'xampp.exe': 'XAMPP',
      'wamp.exe': 'WAMP',
      'node.exe': 'Node.js',
      'python.exe': 'Python',
      'java.exe': 'Java Runtime',
      'javac.exe': 'Java Compiler',
      'gcc.exe': 'GCC Compiler',
      'cl.exe': 'MSVC Compiler',
      
      // Office & Productivity
      'winword.exe': 'Microsoft Word',
      'excel.exe': 'Microsoft Excel',
      'powerpnt.exe': 'Microsoft PowerPoint',
      'outlook.exe': 'Microsoft Outlook',
      'access.exe': 'Microsoft Access',
      'publisher.exe': 'Microsoft Publisher',
      'onenote.exe': 'Microsoft OneNote',
      'teams.exe': 'Microsoft Teams',
      'skype.exe': 'Skype',
      'lync.exe': 'Lync',
      'libreoffice.exe': 'LibreOffice',
      'openoffice.exe': 'Apache OpenOffice',
      'wps.exe': 'WPS Office',
      'kingsoft.exe': 'Kingsoft Office',
      'googlechrome.exe': 'Google Chrome',
      'chrome.exe': 'Google Chrome',
      'firefox.exe': 'Mozilla Firefox',
      'msedge.exe': 'Microsoft Edge',
      'opera.exe': 'Opera Browser',
      'brave.exe': 'Brave Browser',
      'safari.exe': 'Safari',
      'vivaldi.exe': 'Vivaldi Browser',
      'tor.exe': 'Tor Browser',
      
      // File Management & Utilities
      'explorer.exe': 'File Explorer',
      'totalcommander.exe': 'Total Commander',
      'freecommander.exe': 'FreeCommander',
      'xyplorer.exe': 'XYplorer',
      'winrar.exe': 'WinRAR',
      '7zfm.exe': '7-Zip',
      'winzip.exe': 'WinZip',
      'peazip.exe': 'PeaZip',
      'bandizip.exe': 'Bandizip',
      'utorrent.exe': 'uTorrent',
      'qbittorrent.exe': 'qBittorrent',
      'transmission.exe': 'Transmission',
      'deluge.exe': 'Deluge',
      'ccleaner.exe': 'CCleaner',
      'malwarebytes.exe': 'Malwarebytes',
      'avast.exe': 'Avast Antivirus',
      'norton.exe': 'Norton Antivirus',
      'mcafee.exe': 'McAfee Antivirus',
      'teamviewer.exe': 'TeamViewer',
      'anydesk.exe': 'AnyDesk',
      'ultraviewer.exe': 'UltraViewer',
      'logmein.exe': 'LogMeIn',
      
      // Creative & Media
      'spotify.exe': 'Spotify',
      'vlc.exe': 'VLC Media Player',
      'potplayer.exe': 'PotPlayer',
      'mpc.exe': 'Media Player Classic',
      'kodi.exe': 'Kodi',
      'itunes.exe': 'iTunes',
      'windowsmediaplayer.exe': 'Windows Media Player',
      'wmp.exe': 'Windows Media Player',
      'quicktime.exe': 'QuickTime',
      'discord.exe': 'Discord',
      'telegram.exe': 'Telegram',
      'whatsapp.exe': 'WhatsApp',
      'slack.exe': 'Slack',
      'zoom.exe': 'Zoom',
      'skype.exe': 'Skype',
      'teams.exe': 'Microsoft Teams',
      'webex.exe': 'Cisco Webex',
      'gotomeeting.exe': 'GoToMeeting',
      
      // Gaming & Entertainment
      'steam.exe': 'Steam',
      'epicgameslauncher.exe': 'Epic Games Launcher',
      'origin.exe': 'Origin',
      'uplay.exe': 'Ubisoft Connect',
      'battle.net.exe': 'Battle.net',
      'minecraft.exe': 'Minecraft',
      'roblox.exe': 'Roblox',
      'fortnite.exe': 'Fortnite',
      'leagueoflegends.exe': 'League of Legends',
      'valorant.exe': 'Valorant',
      'csgo.exe': 'Counter-Strike: Global Offensive',
      'dota2.exe': 'Dota 2',
      'overwatch.exe': 'Overwatch',
      'apex.exe': 'Apex Legends',
      'pubg.exe': 'PUBG',
      'gta5.exe': 'Grand Theft Auto V',
      'reddeadredemption2.exe': 'Red Dead Redemption 2',
      'cyberpunk2077.exe': 'Cyberpunk 2077',
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
      saveSettings(); // Auto save settings when selection changes
      notifyListeners();
    }
  }

  // Refresh danh sách ứng dụng để loại bỏ các process không còn tồn tại
  Future<void> refreshApplications() async {
    await loadApplications();
    notifyListeners();
  }

  // Thêm method để lấy tất cả process names của một ứng dụng
  List<String> getProcessNamesForApp(int index) {
    if (index >= 0 && index < applications.length) {
      return applications[index].processName.split(', ');
    }
    return [];
  }

  // Load settings từ SharedPreferences
  Future<void> loadSettings() async {
    try {
      final settings = await AppSettings.loadAllSettings();
      interval = settings['interval'];
      autoRun = settings['autoRun'];
      minimizeToTray = settings['minimizeToTray'];
      showNotifications = settings['showNotifications'];
      
      // Load selected apps
      final selectedAppNames = settings['selectedApps'] as List<String>;
      for (final app in applications) {
        app.isSelected = selectedAppNames.contains(app.name);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save settings
  Future<void> saveSettings() async {
    try {
      final selectedAppNames = applications
          .where((app) => app.isSelected)
          .map((app) => app.name)
          .toList();

      await AppSettings.saveAllSettings(
        selectedApps: selectedAppNames,
        interval: interval,
        autoRun: autoRun,
        minimizeToTray: minimizeToTray,
        showNotifications: showNotifications,
        useWindowsNotification: useWindowsNotification,
      );
    } catch (e) {
      print('Error saving settings: $e');
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
    saveSettings();
    notifyListeners();
  }

  // Removed: setOnlyActiveWindow method - no longer needed

  void setAutoRun(bool value) async {
    autoRun = value;
    saveSettings();
    
    // Cập nhật auto-start trong Windows Registry
    if (value) {
      await AutoStartService.enableAutoStart();
    } else {
      await AutoStartService.disableAutoStart();
    }
    
    notifyListeners();
  }

  void setMinimizeToTray(bool value) {
    minimizeToTray = value;
    saveSettings();
    notifyListeners();
  }

  void setShowNotifications(bool value) {
    showNotifications = value;
    saveSettings();
    notifyListeners();
  }

  void setUseWindowsNotification(bool value) {
    useWindowsNotification = value;
    saveSettings();
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

  // Test gửi Ctrl+S đến ứng dụng đang active
  Future<void> testCtrlS() async {
    print('Testing Ctrl+S to active window...');
    final success = await KeyboardService.testCtrlS();
    if (success) {
      print('✅ Test Ctrl+S successful');
    } else {
      print('❌ Test Ctrl+S failed');
    }
  }

  // Test gửi Ctrl+S đến REAPER
  Future<void> testReaperSave() async {
    print('Testing REAPER save...');
    final success = await KeyboardService.testReaperSave();
    if (success) {
      print('✅ Test REAPER save successful');
    } else {
      print('❌ Test REAPER save failed');
    }
  }

  // Test gửi Ctrl+S đến active window
  Future<void> testActiveWindowSave() async {
    print('Testing active window save...');
    final success = await KeyboardService.testCtrlS();
    if (success) {
      print('✅ Test active window save successful');
    } else {
      print('❌ Test active window save failed');
    }
  }

  // Test logic mới: kiểm tra active window có trong danh sách ứng dụng được chọn không
  Future<void> testActiveWindowInSelectedApps() async {
    print('Testing if active window is in selected apps list...');
    
    if (selectedApplications.isEmpty) {
      print('❌ No applications selected');
      return;
    }
    
    // Lấy danh sách tất cả process names của các ứng dụng được chọn
    final selectedProcessNames = <String>[];
    for (final app in selectedApplications) {
      final processNames = app.processName.split(', ');
      for (final processName in processNames) {
        selectedProcessNames.add(processName.trim());
      }
    }
    
    print('Selected process names: ${selectedProcessNames.join(', ')}');
    
    final isInSelected = await KeyboardService.isActiveWindowInSelectedApps(selectedProcessNames);
    
    if (isInSelected) {
      print('✅ Active window is in selected apps list');
    } else {
      print('❌ Active window is NOT in selected apps list');
    }
  }

  // Test gửi Ctrl+S đến active window nếu nó thuộc danh sách ứng dụng được chọn
  Future<void> testSendCtrlSToActiveWindowIfSelected() async {
    print('Testing send Ctrl+S to active window if selected...');
    
    if (selectedApplications.isEmpty) {
      print('❌ No applications selected');
      return;
    }
    
    // Lấy danh sách tất cả process names của các ứng dụng được chọn
    final selectedProcessNames = <String>[];
    for (final app in selectedApplications) {
      final processNames = app.processName.split(', ');
      for (final processName in processNames) {
        selectedProcessNames.add(processName.trim());
      }
    }
    
    print('Selected process names: ${selectedProcessNames.join(', ')}');
    
    final success = await KeyboardService.sendCtrlSToActiveWindowIfSelected(selectedProcessNames);
    
    if (success) {
      print('✅ Successfully sent Ctrl+S to active window');
    } else {
      print('❌ Failed to send Ctrl+S to active window (not in selected apps or failed)');
    }
  }

  // Test function: Chạy save function sau 5 giây
  Future<void> testSaveAfter5Seconds() async {
    print('Starting 5-second countdown for save test...');
    
    if (selectedApplications.isEmpty) {
      print('❌ No applications selected');
      await TrayService.showNotification(
        title: 'Test Auto Save',
        body: 'Vui lòng chọn ít nhất một ứng dụng để test',
        useWindowsNotification: true,
      );
      return;
    }
    
    // Hiển thị notification thông báo cho user
    await TrayService.showNotification(
      title: 'Test Auto Save',
      body: 'Bạn có 5 giây để chuyển về ứng dụng cần lưu. Hệ thống sẽ tự động lưu sau 5 giây.',
      useWindowsNotification: true,
    );
    
    print('⏰ Starting 5-second countdown...');
    print('📝 Please switch to an application that needs saving');
    
    // Đếm ngược
    for (int i = 5; i > 0; i--) {
      await Future.delayed(Duration(seconds: 1));
      print('⏰ Countdown: $i seconds remaining...');
    }
    
    print('🚀 Executing save function now...');
    
    // Chạy save function
    await _doSave();
    
    print('✅ Test save function completed');
    
    // Hiển thị notification kết quả
    await TrayService.showNotification(
      title: 'Test Auto Save',
      body: 'Test hoàn thành! Kiểm tra log để xem kết quả.',
      useWindowsNotification: true,
    );
  }

  // Test function tổng hợp: Test toàn bộ logic
  Future<void> testCompleteLogic() async {
    print('🧪 Starting complete logic test...');
    
    if (selectedApplications.isEmpty) {
      print('❌ No applications selected');
      await TrayService.showNotification(
        title: 'Complete Test',
        body: 'Vui lòng chọn ít nhất một ứng dụng để test',
        useWindowsNotification: true,
      );
      return;
    }
    
    // Bước 1: Kiểm tra active window
    print('📋 Step 1: Checking active window...');
    final selectedProcessNames = <String>[];
    for (final app in selectedApplications) {
      final processNames = app.processName.split(', ');
      for (final processName in processNames) {
        selectedProcessNames.add(processName.trim());
      }
    }
    
    final isInSelected = await KeyboardService.isActiveWindowInSelectedApps(selectedProcessNames);
    print('Active window in selected apps: $isInSelected');
    
    // Bước 2: Thông báo cho user
    await TrayService.showNotification(
      title: 'Complete Test',
      body: isInSelected 
          ? 'Active window is in selected apps. Starting save test in 3 seconds...'
          : 'Active window is NOT in selected apps. Switch to target app in 3 seconds...',
      useWindowsNotification: true,
    );
    
    // Bước 3: Đếm ngược 3 giây
    print('⏰ Countdown: 3 seconds...');
    await Future.delayed(Duration(seconds: 1));
    print('⏰ Countdown: 2 seconds...');
    await Future.delayed(Duration(seconds: 1));
    print('⏰ Countdown: 1 second...');
    await Future.delayed(Duration(seconds: 1));
    
    // Bước 4: Thực hiện save
    print('🚀 Executing save function...');
    await _doSave();
    
    print('✅ Complete test finished');
    
    // Bước 5: Thông báo kết quả
    await TrayService.showNotification(
      title: 'Complete Test',
      body: 'Test hoàn thành! Kiểm tra log để xem kết quả chi tiết.',
      useWindowsNotification: true,
    );
  }

  // Test notification system
  Future<void> testNotificationSystem() async {
    print('🔔 Testing notification system...');
    
    // Test 1: Windows notification
    await TrayService.showNotification(
      title: 'Test Notification',
      body: 'Đây là test notification Windows native',
      useWindowsNotification: true,
    );
    
    await Future.delayed(Duration(seconds: 2));
    
    // Test 2: MessageBox notification
    await TrayService.showNotification(
      title: 'Test MessageBox',
      body: 'Đây là test notification MessageBox',
      useWindowsNotification: false,
    );
    
    print('✅ Notification test completed');
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

    final savedApps = <String>[];
    bool hasError = false;

    try {
      // Lấy danh sách tất cả process names của các ứng dụng được chọn
      final selectedProcessNames = <String>[];
      for (final app in selectedApplications) {
        final processNames = app.processName.split(', ');
        for (final processName in processNames) {
          selectedProcessNames.add(processName.trim());
        }
      }
      
      // Sử dụng logic mới: chỉ gửi Ctrl+S nếu active window thuộc danh sách ứng dụng được chọn
      print('Checking if active window is in selected apps list...');
      final success = await KeyboardService.sendCtrlSToActiveWindowIfSelected(selectedProcessNames);
      
      if (success) {
        // Lấy tên của active window để log
        final activeWindowApp = await _getActiveWindowAppName(selectedProcessNames);
        if (activeWindowApp != null) {
          savedApps.add(activeWindowApp);
        }
        
        // Tạo log cho việc save thành công
        final log = SaveLog(
          appName: activeWindowApp ?? 'Active Window',
          processName: 'Active Window',
          timestamp: DateTime.now(),
          success: true,
        );
        saveLogs.add(log);
        
        print('✅ Auto-saved active window successfully');
      } else {
        print('❌ Active window is not in selected apps list or save failed');
        
        // Tạo log cho việc không save
        final log = SaveLog(
          appName: 'Active Window',
          processName: 'Active Window',
          timestamp: DateTime.now(),
          success: false,
        );
        saveLogs.add(log);
      }
      
      notifyListeners();
      
      // Hiển thị notification
      if (showNotifications) {
        await TrayService.showAutoSaveNotification(
          savedApps: savedApps,
          success: savedApps.isNotEmpty,
          useWindowsNotification: useWindowsNotification,
        );
      }
      
    } catch (e) {
      print('Error during auto-save: $e');
      hasError = true;
      
      // Add error logs
      final log = SaveLog(
        appName: 'Active Window',
        processName: 'Active Window',
        timestamp: DateTime.now(),
        success: false,
      );
      saveLogs.add(log);
      
      notifyListeners();

      // Hiển thị notification lỗi
      if (showNotifications) {
        await TrayService.showAutoSaveNotification(
          savedApps: [],
          success: false,
        );
      }
    }
  }

  /// Lấy tên ứng dụng của active window
  Future<String?> _getActiveWindowAppName(List<String> selectedProcessNames) async {
    try {
      final result = await Process.run('powershell', [
        '-Command',
        '''
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();
            
            [DllImport("user32.dll")]
            public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
            
            [DllImport("kernel32.dll")]
            public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);
            
            [DllImport("kernel32.dll")]
            public static extern bool QueryFullProcessImageName(IntPtr hprocess, int dwFlags, System.Text.StringBuilder lpExeName, ref int lpdwSize);
        }
"@

        \$activeHwnd = [Win32]::GetForegroundWindow()
        if (\$activeHwnd -eq [IntPtr]::Zero) {
            Write-Host "No active window found"
            exit 1
        }
        
        \$processId = 0
        [Win32]::GetWindowThreadProcessId(\$activeHwnd, [ref] \$processId)
        
        if (\$processId -eq 0) {
            Write-Host "Could not get process ID for active window"
            exit 1
        }
        
        \$processHandle = [Win32]::OpenProcess(0x1000, \$false, \$processId)
        if (\$processHandle -eq [IntPtr]::Zero) {
            Write-Host "Could not open process handle"
            exit 1
        }
        
        \$exeName = New-Object System.Text.StringBuilder(260)
        \$size = 260
        \$result = [Win32]::QueryFullProcessImageName(\$processHandle, 0, \$exeName, [ref] \$size)
        
        if (\$result) {
            \$fullPath = \$exeName.ToString()
            \$processName = [System.IO.Path]::GetFileName(\$fullPath)
            Write-Host "Active window process: \$processName"
        } else {
            Write-Host "Could not get process name"
            exit 1
        }
        '''
      ]);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('Active window process:')) {
            final processName = line.split('Active window process:').last.trim();
            return processName;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting active window app name: $e');
      return null;
    }
  }
}
