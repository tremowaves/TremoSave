import 'package:auto_saver/models/app_state.dart';
import 'package:auto_saver/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tremo Save',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}
