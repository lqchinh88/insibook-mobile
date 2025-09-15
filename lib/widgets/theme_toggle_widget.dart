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
          trailing: const ThemeToggleWidget(),
          onTap: () {
            // This will be handled by the ThemeToggleWidget's PopupMenuButton
          },
        );
      },
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