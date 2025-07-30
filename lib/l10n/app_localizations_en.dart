// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tremo Save';

  @override
  String get welcomeTitle => 'Smart Auto Save';

  @override
  String get welcomeSubtitle => 'Manage and protect your work';

  @override
  String get welcomeDescription => 'Select the applications you want to auto-save. The system will monitor and save your work when you are using the selected applications.';

  @override
  String get selectApps => 'Select Applications';

  @override
  String get autoSaveSettings => 'Auto Save Settings';

  @override
  String get saveInterval => 'Auto save interval:';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get startAutoSave => 'Start Auto Save';

  @override
  String get stopAutoSave => 'Stop Auto Save';

  @override
  String get applications => 'Applications';

  @override
  String get interval => 'Interval';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get paused => 'Paused';

  @override
  String get saveHistory => 'Save History';

  @override
  String get latestTime => 'Latest Time';

  @override
  String get appName => 'App Name';

  @override
  String get clearAllLogs => 'Clear all logs';

  @override
  String get noSaveHistory => 'No save history yet';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String totalSaves(int count) {
    return 'Total $count saves';
  }

  @override
  String successCount(int success, int error) {
    return '$success successful, $error errors';
  }

  @override
  String get selectAtLeastOneApp => 'Please select at least one application to start auto save';

  @override
  String get toggleDarkMode => 'Switch to light mode';

  @override
  String get toggleLightMode => 'Switch to dark mode';

  @override
  String get showSaveHistory => 'Show save history';

  @override
  String get refreshApps => 'Refresh application list';

  @override
  String get settings => 'Settings';

  @override
  String get testSaveAfter5s => 'Test Save After 5s';

  @override
  String get testNotifications => 'Test Notifications';

  @override
  String get startingTest => 'Starting 5-second test. Switch to target application now!';

  @override
  String get testingNotifications => 'Testing notification system...';
}
