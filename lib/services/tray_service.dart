import 'dart:io';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:auto_saver/models/app_settings.dart';
import 'package:local_notifier/local_notifier.dart';

class TrayService {
  static const String _trayIconPath = 'assets/tray_icon.png';
  static const String _appName = 'Tremo Save';
  
  static bool _isInitialized = false;
  static VoidCallback? _onShowApp;
  static VoidCallback? _onStartAutoSave;
  static VoidCallback? _onStopAutoSave;
  static VoidCallback? _onExit;

  static Future<void> initialize({
    required VoidCallback onShowApp,
    required VoidCallback onStartAutoSave,
    required VoidCallback onStopAutoSave,
    required VoidCallback onExit,
  }) async {
    if (_isInitialized) return;

    _onShowApp = onShowApp;
    _onStartAutoSave = onStartAutoSave;
    _onStopAutoSave = onStopAutoSave;
    _onExit = onExit;

    try {
      // TODO: Implement system tray when package is properly configured
      // Hiện tại sử dụng placeholder, nhưng có thể mở rộng sau
      print('System tray initialized (placeholder)');
      print('Available callbacks:');
      print('  - onShowApp: ${_onShowApp != null ? 'registered' : 'null'}');
      print('  - onStartAutoSave: ${_onStartAutoSave != null ? 'registered' : 'null'}');
      print('  - onStopAutoSave: ${_onStopAutoSave != null ? 'registered' : 'null'}');
      print('  - onExit: ${_onExit != null ? 'registered' : 'null'}');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing system tray: $e');
    }
  }

    static Future<void> showNotification({
    required String title,
    required String body,
    String? iconPath,
  }) async {
    try {
      // Sử dụng local_notifier cho Windows toast notification
      final notification = LocalNotification(
        title: title,
        body: body,
      );
      
      await notification.show();
      print('Notification shown: $title - $body');
    } catch (e) {
      print('Error showing notification: $e');
      // Fallback: sử dụng print để debug
      print('NOTIFICATION: $title - $body');
    }
  }

  static Future<void> showAutoSaveNotification({
    required List<String> savedApps,
    required bool success,
  }) async {
    final settings = await AppSettings.loadAllSettings();
    if (!settings['showNotifications']) return;

    final title = success ? 'Auto Save thành công' : 'Auto Save thất bại';
    final body = success 
        ? 'Đã lưu ${savedApps.length} ứng dụng: ${savedApps.take(3).join(', ')}${savedApps.length > 3 ? '...' : ''}'
        : 'Không thể lưu các ứng dụng đã chọn';

    await showNotification(
      title: title,
      body: body,
    );
  }

  static Future<void> destroy() async {
    try {
      _isInitialized = false;
      print('System tray destroyed');
    } catch (e) {
      print('Error destroying system tray: $e');
    }
  }
} 