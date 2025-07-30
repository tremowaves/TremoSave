import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tremo_save/services/language_service.dart';
import 'package:tremo_save/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final l10n = AppLocalizations.of(context);
        
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Change Language',
          onSelected: (String languageCode) async {
            print('LanguageSelector: Changing language to $languageCode');
            await languageService.setLanguage(languageCode);
            print('LanguageSelector: Language changed to ${languageService.currentLocale.languageCode}');
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'vi',
              child: Row(
                children: [
                  Text('🇻🇳', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('Tiếng Việt'),
                  if (languageService.isVietnamese)
                    const Icon(Icons.check, size: 16, color: Colors.green),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('English'),
                  if (languageService.isEnglish)
                    const Icon(Icons.check, size: 16, color: Colors.green),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 