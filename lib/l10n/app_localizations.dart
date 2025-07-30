import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Tremo Save'**
  String get appTitle;

  /// Welcome card title
  ///
  /// In en, this message translates to:
  /// **'Smart Auto Save'**
  String get welcomeTitle;

  /// Welcome card subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage and protect your work'**
  String get welcomeSubtitle;

  /// Welcome card description
  ///
  /// In en, this message translates to:
  /// **'Select the applications you want to auto-save. The system will monitor and save your work when you are using the selected applications.'**
  String get welcomeDescription;

  /// App selector card title
  ///
  /// In en, this message translates to:
  /// **'Select Applications'**
  String get selectApps;

  /// Settings card title
  ///
  /// In en, this message translates to:
  /// **'Auto Save Settings'**
  String get autoSaveSettings;

  /// Save interval label
  ///
  /// In en, this message translates to:
  /// **'Auto save interval:'**
  String get saveInterval;

  /// Minutes with count
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// Start auto save button
  ///
  /// In en, this message translates to:
  /// **'Start Auto Save'**
  String get startAutoSave;

  /// Stop auto save button
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Save'**
  String get stopAutoSave;

  /// Applications stat label
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// Interval stat label
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Status stat label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Paused status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Log panel title
  ///
  /// In en, this message translates to:
  /// **'Save History'**
  String get saveHistory;

  /// Sort by time option
  ///
  /// In en, this message translates to:
  /// **'Latest Time'**
  String get latestTime;

  /// Sort by app name option
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// Clear logs button tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear all logs'**
  String get clearAllLogs;

  /// Empty log message
  ///
  /// In en, this message translates to:
  /// **'No save history yet'**
  String get noSaveHistory;

  /// Success status
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Error status
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Total saves count
  ///
  /// In en, this message translates to:
  /// **'Total {count} saves'**
  String totalSaves(int count);

  /// Success and error count
  ///
  /// In en, this message translates to:
  /// **'{success} successful, {error} errors'**
  String successCount(int success, int error);

  /// Info banner message
  ///
  /// In en, this message translates to:
  /// **'Please select at least one application to start auto save'**
  String get selectAtLeastOneApp;

  /// Dark mode toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get toggleDarkMode;

  /// Light mode toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get toggleLightMode;

  /// Show logs tooltip
  ///
  /// In en, this message translates to:
  /// **'Show save history'**
  String get showSaveHistory;

  /// Refresh apps tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh application list'**
  String get refreshApps;

  /// Settings tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Test save tooltip
  ///
  /// In en, this message translates to:
  /// **'Test Save After 5s'**
  String get testSaveAfter5s;

  /// Test notifications tooltip
  ///
  /// In en, this message translates to:
  /// **'Test Notifications'**
  String get testNotifications;

  /// Test start message
  ///
  /// In en, this message translates to:
  /// **'Starting 5-second test. Switch to target application now!'**
  String get startingTest;

  /// Notification test message
  ///
  /// In en, this message translates to:
  /// **'Testing notification system...'**
  String get testingNotifications;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
