import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rich_home_screen.dart';
import 'book_search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'login_required_screen.dart';
import 'auth/login_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LanguageProvider>(
      builder: (context, authProvider, languageProvider, child) {
        final screens = [
          const RichHomeScreen(),
          const BookSearchScreen(),
          // Library tab: show LibraryScreen regardless of auth (it handles auth check internally)
          const LibraryScreen(),
          // Profile tab: show ProfileScreen if authenticated, LoginRequiredScreen if not
          authProvider.isAuthenticated 
            ? const ProfileScreen() 
            : const LoginRequiredScreen(),
        ];

        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              
              // If user taps Library tab and not authenticated, immediately push LoginScreen
              if (index == 2 && !authProvider.isAuthenticated) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
              
              // If user taps Profile tab and not authenticated, immediately push LoginScreen
              if (index == 3 && !authProvider.isAuthenticated) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: languageProvider.l10n['home'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: languageProvider.l10n['search'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.library_books),
                label: languageProvider.l10n['library'],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: languageProvider.l10n['profile'],
              ),
            ],
          ),
        );
      },
    );
  }
}