import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'rich_home_screen.dart';
import 'curated_collection_scroll_spinning_screen.dart';
import 'curated_collection_journey_screen.dart';
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

  void _showCuratedCollectionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Curated Collections',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore thoughtfully selected literary journeys',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Scroll Spinning Collection
              _buildCollectionOption(
                icon: Icons.auto_stories_rounded,
                title: 'Scroll Spinning Collection',
                description: 'Dynamic book reveal with spinning animations',
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CuratedCollectionScrollSpinningScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Curatorial Journey
              _buildCollectionOption(
                icon: Icons.menu_book_rounded,
                title: 'A Curated Journey',
                description: 'Literary exhibition with thoughtful commentary',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CuratedCollectionJourneyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

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
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: _showCuratedCollectionsMenu,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.auto_stories_rounded),
                )
              : null,
          bottomNavigationBar: FBottomNavigationBar(
            index: _currentIndex,
            onChange: (index) {
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
            children: [
              FBottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: Text(languageProvider.l10n['home']),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: Text(languageProvider.l10n['search']),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(Icons.library_books),
                label: Text(languageProvider.l10n['library']),
              ),
              FBottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: Text(languageProvider.l10n['profile']),
              ),
            ],
          ),
        );
      },
    );
  }
}