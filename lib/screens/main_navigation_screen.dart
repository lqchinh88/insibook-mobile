import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rich_home_screen.dart';
import 'book_search_screen.dart';
import 'profile_screen.dart';
import 'login_required_screen.dart';
import 'auth/login_screen.dart';
import '../providers/auth_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final screens = [
          const RichHomeScreen(),
          const BookSearchScreen(),
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
              
              // If user taps Profile tab and not authenticated, immediately push LoginScreen
              if (index == 2 && !authProvider.isAuthenticated) {
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}