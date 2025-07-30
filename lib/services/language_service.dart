import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('vi'); // Default to Vietnamese
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  LanguageService() {
    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    await _loadLanguage();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
      }
    } catch (e) {
      // Fallback to default locale if there's an error
      _currentLocale = const Locale('vi');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return; // No change needed
    
    _currentLocale = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Continue even if saving fails
    }
    notifyListeners();
  }

  Future<void> setVietnamese() async {
    await setLanguage('vi');
  }

  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  bool get isVietnamese => _currentLocale.languageCode == 'vi';
  bool get isEnglish => _currentLocale.languageCode == 'en';
} 