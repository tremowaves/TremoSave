import 'dart:io';
import 'package:win32/win32.dart';

class KeyboardService {
  /// Kiểm tra xem active window có thuộc danh sách ứng dụng được chọn không
  static Future<bool> isActiveWindowInSelectedApps(List<String> selectedProcessNames) async {
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
        
        \$processHandle = [Win32]::OpenProcess(0x1000, \$false, \$processId) # PROCESS_QUERY_LIMITED_INFORMATION
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
            
            \$selectedApps = @(${selectedProcessNames.map((name) => '"$name"').join(', ')})
            foreach (\$selectedApp in \$selectedApps) {
                if (\$processName -like "*\$selectedApp*" -or \$selectedApp -like "*\$processName*") {
                    Write-Host "Active window is in selected apps list"
                    exit 0
                }
            }
            
            Write-Host "Active window is NOT in selected apps list"
            exit 1
        } else {
            Write-Host "Could not get process name"
            exit 1
        }
        '''
      ]);
      
      return result.exitCode == 0;
    } catch (e) {
      print('Error checking active window: $e');
      return false;
    }
  }

  /// Gửi Ctrl+S đến active window nếu nó thuộc danh sách ứng dụng được chọn
  static Future<bool> sendCtrlSToActiveWindowIfSelected(List<String> selectedProcessNames) async {
    try {
      // Kiểm tra xem active window có thuộc danh sách ứng dụng được chọn không
      final isInSelected = await isActiveWindowInSelectedApps(selectedProcessNames);
      
      if (!isInSelected) {
        print('Active window is not in selected apps list, skipping Ctrl+S');
        return false;
      }
      
      // Nếu active window thuộc danh sách, gửi Ctrl+S
      print('Active window is in selected apps list, sending Ctrl+S...');
      final result = await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait("^s")'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ Ctrl+S sent successfully to active window');
        return true;
      } else {
        print('❌ Failed to send Ctrl+S: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Error sending Ctrl+S to active window: $e');
      return false;
    }
  }

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
      // Phương pháp 1: Gửi Ctrl+S đến active window (đơn giản nhất)
      print('Sending Ctrl+S to active window for $processName...');
      final simpleResult = await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait("^s"); Write-Host "Ctrl+S sent to active window"'
      ]);
      
      if (simpleResult.exitCode == 0) {
        print('✅ Simple Ctrl+S sent successfully');
        return true;
      }
      
      // Phương pháp 2: Focus vào ứng dụng trước khi gửi Ctrl+S
      print('Trying to focus $processName before sending Ctrl+S...');
      final focusResult = await Process.run('powershell', [
        '-Command',
        '''
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
            
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
            
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();
            
            [DllImport("user32.dll")]
            public static extern bool AttachThreadInput(IntPtr idAttach, IntPtr idAttachTo, bool fAttach);
            
            [DllImport("kernel32.dll")]
            public static extern IntPtr GetCurrentThreadId();
        }
"@

        Add-Type -AssemblyName System.Windows.Forms
        
        Write-Host "Looking for process: $processName"
        \$processes = Get-Process -Name "$processName" -ErrorAction SilentlyContinue
        if (\$processes) {
            Write-Host "Found \$(\$processes.Count) processes for $processName"
            foreach (\$proc in \$processes) {
                Write-Host "  - \$(\$proc.ProcessName).exe"
            }
        } else {
            Write-Host "No processes found with Get-Process, trying alternative method..."
            \$allProcesses = Get-Process | Where-Object { \$_.ProcessName -like "*$processName*" }
            if (\$allProcesses) {
                Write-Host "Found \$(\$allProcesses.Count) processes with alternative search:"
                foreach (\$proc in \$allProcesses) {
                    Write-Host "  - \$(\$proc.ProcessName).exe"
                }
                \$processes = \$allProcesses
            }
        }
            foreach (\$proc in \$processes) {
                Write-Host "Process: \$(\$proc.ProcessName), Window: \$(\$proc.MainWindowTitle)"
                if (\$proc.MainWindowTitle -ne "") {
                    \$hwnd = [Win32]::FindWindow(\$null, \$proc.MainWindowTitle)
                    Write-Host "Window handle: \$hwnd"
                    if (\$hwnd -ne [IntPtr]::Zero) {
                        # Lưu window hiện tại
                        \$currentHwnd = [Win32]::GetForegroundWindow()
                        Write-Host "Current window: \$currentHwnd"
                        
                        # Focus vào ứng dụng
                        \$focusResult = [Win32]::SetForegroundWindow(\$hwnd)
                        Write-Host "Focus result: \$focusResult"
                        [Win32]::ShowWindow(\$hwnd, 5) # SW_SHOW
                        Start-Sleep -Milliseconds 500
                        
                        # Kiểm tra xem window có thực sự được focus không
                        \$currentFocus = [Win32]::GetForegroundWindow()
                        Write-Host "Current focus after SetForegroundWindow: \$currentFocus"
                        
                        if (\$currentFocus -eq \$hwnd) {
                            # Gửi Ctrl+S
                            [System.Windows.Forms.SendKeys]::SendWait("^s")
                            Start-Sleep -Milliseconds 200
                            Write-Host "Ctrl+S sent to $processName successfully"
                        } else {
                            Write-Host "Failed to focus window - trying alternative method"
                            # Thử phương pháp khác
                            \$shell = New-Object -ComObject Shell.Application
                            \$shell.MinimizeAll()
                            Start-Sleep -Milliseconds 100
                            [Win32]::SetForegroundWindow(\$hwnd)
                            Start-Sleep -Milliseconds 300
                            [System.Windows.Forms.SendKeys]::SendWait("^s")
                            Start-Sleep -Milliseconds 200
                            Write-Host "Ctrl+S sent to $processName using alternative method"
                        }
                        
                        # Trở về window trước đó
                        [Win32]::SetForegroundWindow(\$currentHwnd)
                        
                        Write-Host "Ctrl+S sent to $processName successfully"
                        break
                    } else {
                        Write-Host "Failed to find window handle"
                    }
                } else {
                    Write-Host "Process has no main window"
                }
            }
        } else {
            Write-Host "No processes found for $processName"
        }
        '''
      ]);
      
      if (focusResult.exitCode == 0) {
        // Kiểm tra output để xem có thực sự thành công không
        final output = focusResult.stdout.toString();
        if (output.contains('Ctrl+S sent to $processName successfully')) {
          print('✅ Ctrl+S sent to $processName successfully');
          return true;
        } else {
          print('❌ Ctrl+S failed to $processName: $output');
          return false;
        }
      } else {
        print('❌ Failed to send Ctrl+S to $processName: ${focusResult.stderr}');
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

  /// Test gửi Ctrl+S đến ứng dụng đang active
  static Future<bool> testCtrlS() async {
    try {
      final result = await Process.run('powershell', [
        '-Command',
        '''
        Add-Type -AssemblyName System.Windows.Forms
        Write-Host "Sending Ctrl+S to active window..."
        [System.Windows.Forms.SendKeys]::SendWait("^s")
        Write-Host "Ctrl+S sent to active window"
        '''
      ]);
      
      if (result.exitCode == 0) {
        print('✅ Test Ctrl+S successful');
        return true;
      } else {
        print('❌ Test Ctrl+S failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Error testing Ctrl+S: $e');
      return false;
    }
  }

  /// Test focus vào REAPER và gửi Ctrl+S
  static Future<bool> testReaperSave() async {
    try {
      final result = await Process.run('powershell', [
        '-Command',
        '''
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
            
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
            
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();
        }
"@

        Add-Type -AssemblyName System.Windows.Forms
        
        Write-Host "Checking for REAPER processes..."
        \$processes = Get-Process -Name "reaper" -ErrorAction SilentlyContinue
        if (\$processes) {
            Write-Host "Found \$(\$processes.Count) REAPER processes"
            foreach (\$proc in \$processes) {
                Write-Host "Process: \$(\$proc.ProcessName), Window: \$(\$proc.MainWindowTitle)"
                if (\$proc.MainWindowTitle -ne "") {
                    \$hwnd = [Win32]::FindWindow(\$null, \$proc.MainWindowTitle)
                    Write-Host "Window handle: \$hwnd"
                    if (\$hwnd -ne [IntPtr]::Zero) {
                        \$currentHwnd = [Win32]::GetForegroundWindow()
                        Write-Host "Current window: \$currentHwnd"
                        
                        \$focusResult = [Win32]::SetForegroundWindow(\$hwnd)
                        Write-Host "Focus result: \$focusResult"
                        [Win32]::ShowWindow(\$hwnd, 5)
                        Start-Sleep -Milliseconds 500
                        
                        \$currentFocus = [Win32]::GetForegroundWindow()
                        Write-Host "Current focus after SetForegroundWindow: \$currentFocus"
                        
                        if (\$currentFocus -eq \$hwnd) {
                            [System.Windows.Forms.SendKeys]::SendWait("^s")
                            Write-Host "Ctrl+S sent to REAPER successfully"
                        } else {
                            Write-Host "Failed to focus REAPER window"
                        }
                        break
                    }
                }
            }
        } else {
            Write-Host "No REAPER processes found with Get-Process, trying alternative..."
            \$allProcesses = Get-Process | Where-Object { \$_.ProcessName -like "*reaper*" }
            if (\$allProcesses) {
                Write-Host "Found \$(\$allProcesses.Count) processes with alternative search:"
                foreach (\$proc in \$allProcesses) {
                    Write-Host "  - \$(\$proc.ProcessName).exe"
                }
            } else {
                Write-Host "No REAPER processes found at all"
            }
        }
        '''
      ]);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        if (output.contains('Ctrl+S sent to REAPER successfully')) {
          print('✅ Test REAPER save successful');
          return true;
        } else {
          print('❌ Test REAPER save failed: $output');
          return false;
        }
      } else {
        print('❌ Test REAPER save failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('❌ Error testing REAPER save: $e');
      return false;
    }
  }
} 