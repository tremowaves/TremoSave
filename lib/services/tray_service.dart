import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:auto_saver/models/app_settings.dart';

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
      print('System tray initialized (placeholder)');
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
      final notification = LocalNotification(
        title: title,
        body: body,
      );
      
      await notification.show();
    } catch (e) {
      print('Error showing notification: $e');
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