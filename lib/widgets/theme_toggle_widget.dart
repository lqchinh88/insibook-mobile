import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<ThemeModeOption>(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Change theme',
          onSelected: (option) async {
            await themeProvider.setThemeMode(option);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ThemeModeOption.light,
              child: Row(
                children: [
                  Icon(Icons.light_mode),
                  SizedBox(width: 12),
                  Text('Light'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ThemeModeOption.dark,
              child: Row(
                children: [
                  Icon(Icons.dark_mode),
                  SizedBox(width: 12),
                  Text('Dark'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ThemeModeOption.system,
              child: Row(
                children: [
                  Icon(Icons.settings_brightness),
                  SizedBox(width: 12),
                  Text('System'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ThemeSettingsTile extends StatelessWidget {
  const ThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
          trailing: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onTap: () {
            _showThemeDialog(context, themeProvider);
          },
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: themeProvider.themeMode == ThemeModeOption.light
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                await themeProvider.setThemeMode(ThemeModeOption.light);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: themeProvider.themeMode == ThemeModeOption.dark
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                await themeProvider.setThemeMode(ThemeModeOption.dark);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_brightness),
              title: const Text('System'),
              trailing: themeProvider.themeMode == ThemeModeOption.system
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                await themeProvider.setThemeMode(ThemeModeOption.system);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.system:
        return 'System';
    }
  }
}