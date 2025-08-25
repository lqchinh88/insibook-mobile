import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rich_home_screen.dart';
import 'book_search_screen.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';
import '../providers/auth_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const RichHomeScreen(),
    const BookSearchScreen(),
    const ProfileScreen(), // Will be replaced with login screen if not authenticated
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: _getCurrentScreen(authProvider),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _handleNavigation(index, authProvider),
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

  Widget _getCurrentScreen(AuthProvider authProvider) {
    if (_currentIndex == 2) {
      // Profile tab selected
      if (authProvider.isAuthenticated) {
        return const ProfileScreen();
      } else {
        return const LoginScreen();
      }
    }
    return _screens[_currentIndex];
  }

  void _handleNavigation(int index, AuthProvider authProvider) {
    if (index == 2 && !authProvider.isAuthenticated) {
      // Show a message or handle login navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to view your profile'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    setState(() {
      _currentIndex = index;
    });
  }
}