import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/language_model.dart';
import 'language_selection_dialog.dart';

class LanguageSwitcherTile extends StatelessWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentLanguage = languageProvider.currentLanguageObject;
        
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(languageProvider.l10n['language']),
          subtitle: Text('${currentLanguage.flag} ${currentLanguage.nativeName}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageSelectionDialog(context, languageProvider),
        );
      },
    );
  }

  void _showLanguageSelectionDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    showLanguageSelectionDialog(
      context,
      languageProvider.currentLanguageObject,
      (Language selectedLanguage) async {
        // Show loading snackbar
        final l10n = languageProvider.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n['changing_language_to']} ${selectedLanguage.nativeName}...',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Change the language
        await languageProvider.setLanguage(selectedLanguage.code);
        
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${languageProvider.l10n['language_changed_to']} ${selectedLanguage.nativeName}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}