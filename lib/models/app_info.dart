class AppInfo {
  final String name;
  final String processName;
  bool isSelected;

  AppInfo({
    required this.name,
    required this.processName,
    this.isSelected = false,
  });

  void toggleSelection() {
    isSelected = !isSelected;
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInfo && other.processName == processName;
  }

  @override
  int get hashCode => processName.hashCode;
} 
