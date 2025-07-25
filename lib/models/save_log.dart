class SaveLog {
  final String appName;
  final String processName;
  final DateTime timestamp;
  final bool success;

  SaveLog({
    required this.appName,
    required this.processName,
    required this.timestamp,
    this.success = true,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  String get fullDateTime {
    return '$formattedDate $formattedTime';
  }

  @override
  String toString() {
    return 'SaveLog(appName: $appName, timestamp: $timestamp, success: $success)';
  }
} 