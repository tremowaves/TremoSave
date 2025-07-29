import 'dart:io';

class SimpleNotificationService {
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Sử dụng PowerShell để hiển thị toast notification
      final script = r'''
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipTitle = "$title"
        $notification.BalloonTipText = "$body"
        $notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $notification.Visible = $true
        $notification.ShowBalloonTip(3000)
        
        Start-Sleep -Seconds 3
        $notification.Dispose()
      ''';
      
      final process = await Process.run('powershell', ['-Command', script]);
      
      if (process.exitCode != 0) {
        print('Failed to show notification: ${process.stderr}');
        // Fallback to simple message box
        await _showMessageBox(title, body);
      }
    } catch (e) {
      print('Error showing notification: $e');
      // Fallback to simple message box
      await _showMessageBox(title, body);
    }
  }
  
  static Future<void> _showMessageBox(String title, String body) async {
    try {
      final script = '''
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$body", "$title", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
      ''';
      
      await Process.run('powershell', ['-Command', script]);
    } catch (e) {
      print('Error showing message box: $e');
    }
  }
} 