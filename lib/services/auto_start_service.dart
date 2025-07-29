import 'dart:io';
import 'package:auto_saver/models/app_settings.dart';

class AutoStartService {
  static const String _registryKey = 'Software\\Microsoft\\Windows\\CurrentVersion\\Run';
  static const String _appName = 'Tremo Save';
  static const String _appKey = 'TremoSave';

  /// Kiểm tra xem ứng dụng có được cài đặt auto-start không
  static Future<bool> isAutoStartEnabled() async {
    try {
      final result = await Process.run('reg', [
        'query',
        'HKCU\\$_registryKey',
        '/v',
        _appKey,
      ]);

      return result.exitCode == 0 && result.stdout.toString().contains(_appKey);
    } catch (e) {
      print('Error checking auto-start status: $e');
      return false;
    }
  }

  /// Bật auto-start cho ứng dụng
  static Future<bool> enableAutoStart() async {
    try {
      // Lấy đường dẫn của ứng dụng hiện tại
      final appPath = await _getAppPath();
      if (appPath.isEmpty) {
        print('Could not determine app path');
        return false;
      }

      // Thêm vào registry
      final result = await Process.run('reg', [
        'add',
        'HKCU\\$_registryKey',
        '/v',
        _appKey,
        '/t',
        'REG_SZ',
        '/d',
        '"$appPath"',
        '/f',
      ]);

      if (result.exitCode == 0) {
        print('Auto-start enabled successfully');
        return true;
      } else {
        print('Failed to enable auto-start: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Error enabling auto-start: $e');
      return false;
    }
  }

  /// Tắt auto-start cho ứng dụng
  static Future<bool> disableAutoStart() async {
    try {
      final result = await Process.run('reg', [
        'delete',
        'HKCU\\$_registryKey',
        '/v',
        _appKey,
        '/f',
      ]);

      if (result.exitCode == 0) {
        print('Auto-start disabled successfully');
        return true;
      } else {
        print('Failed to disable auto-start: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Error disabling auto-start: $e');
      return false;
    }
  }

  /// Lấy đường dẫn của ứng dụng hiện tại
  static Future<String> _getAppPath() async {
    try {
      // Trong môi trường production, đây sẽ là đường dẫn đến file .exe
      final currentDir = Directory.current.path;
      final appPath = '$currentDir\\build\\windows\\runner\\Release\\auto_saver.exe';
      
      // Kiểm tra xem file có tồn tại không
      final file = File(appPath);
      if (await file.exists()) {
        return appPath;
      }
      
      // Fallback: sử dụng đường dẫn hiện tại
      return '$currentDir\\auto_saver.exe';
    } catch (e) {
      print('Error getting app path: $e');
      return '';
    }
  }

  /// Cập nhật trạng thái auto-start dựa trên settings
  static Future<void> updateAutoStartStatus() async {
    try {
      final settings = await AppSettings.loadAllSettings();
      final shouldAutoStart = settings['autoRun'] as bool;
      
      final isCurrentlyEnabled = await isAutoStartEnabled();
      
      if (shouldAutoStart && !isCurrentlyEnabled) {
        await enableAutoStart();
      } else if (!shouldAutoStart && isCurrentlyEnabled) {
        await disableAutoStart();
      }
    } catch (e) {
      print('Error updating auto-start status: $e');
    }
  }

  /// Kiểm tra và sửa chữa auto-start nếu cần
  static Future<void> repairAutoStart() async {
    try {
      final settings = await AppSettings.loadAllSettings();
      final shouldAutoStart = settings['autoRun'] as bool;
      
      if (shouldAutoStart) {
        final isEnabled = await isAutoStartEnabled();
        if (!isEnabled) {
          print('Repairing auto-start...');
          await enableAutoStart();
        }
      }
    } catch (e) {
      print('Error repairing auto-start: $e');
    }
  }
} 