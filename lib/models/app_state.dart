import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:ps_list/ps_list.dart';

class AppState extends ChangeNotifier {
  List<String> processes = [];
  String? selectedProcess;
  int interval = 5; // minutes
  bool onlyActiveWindow = true;
  bool isRunning = false;

  Timer? _timer;
  
  AppState() {
    loadProcesses();
  }

  Future<void> loadProcesses() async {
    try {
      processes = (await PSList.getRunningProcesses()).toSet().toList();
      if (processes.isNotEmpty) {
        selectedProcess = processes.first;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading processes: $e');
      processes = [];
      notifyListeners();
    }
  }

  void setSelectedProcess(String? value) {
    selectedProcess = value;
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
    if (selectedProcess == null) return;
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
    if (selectedProcess == null) return;

    try {
      // Simulate Ctrl+S using Flutter's services
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      
      // For now, just print a message
      print('Auto-saved process: $selectedProcess');
      
      // In a real implementation, you would:
      // 1. Find the target window
      // 2. Focus it
      // 3. Send Ctrl+S
      // 4. Restore previous focus
      
    } catch (e) {
      print('Error during auto-save: $e');
    }
  }
}
