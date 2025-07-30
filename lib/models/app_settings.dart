import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _keySelectedApps = 'selected_apps';
  static const String _keyInterval = 'interval';
  static const String _keyOnlyActiveWindow = 'only_active_window';
  static const String _keyAutoRun = 'auto_run';
  static const String _keyMinimizeToTray = 'minimize_to_tray';
  static const String _keyShowNotifications = 'show_notifications';
  // Removed: useWindowsNotification setting - no longer needed

  // Lưu danh sách ứng dụng đã chọn
  static Future<void> saveSelectedApps(List<String> appNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedApps, appNames);
  }

  // Lấy danh sách ứng dụng đã chọn
  static Future<List<String>> getSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySelectedApps) ?? [];
  }

  // Lưu interval
  static Future<void> saveInterval(int interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyInterval, interval);
  }

  // Lấy interval
  static Future<int> getInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInterval) ?? 5;
  }

  // Removed: only active window settings - no longer needed

  // Lưu cài đặt auto run
  static Future<void> saveAutoRun(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRun, value);
  }

  // Lấy cài đặt auto run
  static Future<bool> getAutoRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoRun) ?? false;
  }

  // Lưu cài đặt minimize to tray
  static Future<void> saveMinimizeToTray(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMinimizeToTray, value);
  }

  // Lấy cài đặt minimize to tray
  static Future<bool> getMinimizeToTray() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMinimizeToTray) ?? false;
  }

  // Lưu cài đặt show notifications
  static Future<void> saveShowNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowNotifications, value);
  }

  // Lấy cài đặt show notifications
  static Future<bool> getShowNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowNotifications) ?? true;
  }

  // Removed: useWindowsNotification methods - no longer needed

  // Lưu tất cả settings
  static Future<void> saveAllSettings({
    required List<String> selectedApps,
    required int interval,
    required bool autoRun,
    required bool minimizeToTray,
    required bool showNotifications,
  }) async {
    await saveSelectedApps(selectedApps);
    await saveInterval(interval);
    await saveAutoRun(autoRun);
    await saveMinimizeToTray(minimizeToTray);
    await saveShowNotifications(showNotifications);
  }

  // Load tất cả settings
  static Future<Map<String, dynamic>> loadAllSettings() async => {
      'selectedApps': await getSelectedApps(),
      'interval': await getInterval(),
      'autoRun': await getAutoRun(),
      'minimizeToTray': await getMinimizeToTray(),
      'showNotifications': await getShowNotifications(),
    };
} 
