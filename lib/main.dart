import 'package:tremo_save/models/app_state.dart';
import 'package:tremo_save/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tremo_save/l10n/app_localizations.dart';
import 'package:tremo_save/services/language_service.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:local_notifier/local_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  
  // Khởi tạo local_notifier
  await localNotifier.setup(
    appName: 'Tremo Save',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          title: 'Tremo Save',
          theme: ThemeData(
            primaryColor: Colors.grey[900],
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          locale: languageService.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('vi'), // Vietnamese
          ],
          home: const HomePage(),
        );
      },
    );
  }
}
