import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_model.dart';
import '../providers/language_provider.dart';

class LanguageSelectionDialog extends StatefulWidget {
  final Language currentLanguage;
  final Function(Language) onLanguageSelected;

  const LanguageSelectionDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionDialog> createState() => _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  Language? selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.read<LanguageProvider>().l10n['select_language']),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language list
            ...LanguageConstants.supportedLanguages.map(
              (language) => _buildLanguageItem(language),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.read<LanguageProvider>().l10n['cancel']),
        ),
        FilledButton(
          onPressed: selectedLanguage != widget.currentLanguage
              ? () {
                  widget.onLanguageSelected(selectedLanguage!);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(context.read<LanguageProvider>().l10n['apply']),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(Language language) {
    final isSelected = selectedLanguage?.code == language.code;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedLanguage = language;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Flag
              Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              
              const SizedBox(width: 16),
              
              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (language.name != language.nativeName)
                      Text(
                        language.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Check icon for selected
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the dialog
Future<void> showLanguageSelectionDialog(
  BuildContext context,
  Language currentLanguage,
  Function(Language) onLanguageSelected,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return LanguageSelectionDialog(
        currentLanguage: currentLanguage,
        onLanguageSelected: onLanguageSelected,
      );
    },
  );
}