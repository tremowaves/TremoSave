import 'dart:io';
import 'package:win32/win32.dart';

class KeyboardService {
  /// Gửi Ctrl+S đến ứng dụng đang active
  static Future<bool> sendCtrlS() async {
    try {
      // Sử dụng Windows API để gửi Ctrl+S
      final result = await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait("^s")'
      ]);
      
      if (result.exitCode == 0) {
        print('Ctrl+S sent successfully');
        return true;
      } else {
        print('Failed to send Ctrl+S: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Error sending Ctrl+S: $e');
      return false;
    }
  }

  /// Gửi Ctrl+S đến ứng dụng cụ thể bằng process name
  static Future<bool> sendCtrlSToApp(String processName) async {
    try {
      // Kiểm tra xem ứng dụng có đang chạy không
      final isRunning = await isAppRunning(processName);
      if (!isRunning) {
        print('$processName is not running');
        return false;
      }

      // Gửi Ctrl+S đến ứng dụng đang active
      final result = await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait("^s")'
      ]);
      
      if (result.exitCode == 0) {
        print('Ctrl+S sent to $processName successfully');
        return true;
      } else {
        print('Failed to send Ctrl+S to $processName: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Error sending Ctrl+S to $processName: $e');
      return false;
    }
  }

  /// Gửi Ctrl+S đến tất cả ứng dụng đã chọn
  static Future<List<String>> sendCtrlSToApps(List<String> processNames) async {
    final successfulApps = <String>[];
    
    for (final processName in processNames) {
      final success = await sendCtrlSToApp(processName.trim());
      if (success) {
        successfulApps.add(processName.trim());
      }
    }
    
    return successfulApps;
  }

  /// Kiểm tra xem ứng dụng có đang chạy không
  static Future<bool> isAppRunning(String processName) async {
    try {
      final result = await Process.run('tasklist', ['/FI', 'IMAGENAME eq $processName']);
      return result.exitCode == 0 && result.stdout.toString().contains(processName);
    } catch (e) {
      print('Error checking if $processName is running: $e');
      return false;
    }
  }

  /// Lấy danh sách các ứng dụng đang chạy
  static Future<List<String>> getRunningApps() async {
    try {
      final result = await Process.run('tasklist', ['/FO', 'CSV', '/NH']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        return lines
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
              final parts = line.split(',');
              if (parts.isNotEmpty) {
                return parts[0].replaceAll('"', '');
              }
              return '';
            })
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting running apps: $e');
      return [];
    }
  }
} 