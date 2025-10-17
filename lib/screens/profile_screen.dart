import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../lang/app_localizations.dart';
import '../widgets/language_switcher_tile.dart';
import '../widgets/theme_toggle_widget.dart';
import '../widgets/delete_account_dialog.dart';
import 'reading_progress_screen.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n['profile']),
            elevation: 0,
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user!; // Should not be null when showing this screen

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // User Name
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // User Email
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // User Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.isPaidUser ? 'Premium User' : 'Free User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Role and Member Since
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n['role'],
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatRole(user.role),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n['member_since'],
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(user.createdAt),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Account Actions
                    _buildActionsSection(context, authProvider, l10n),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    return Column(
      children: [
        
        // Theme Toggle
        const ThemeSettingsTile(),
        const Divider(),

        // Language Switcher
        const LanguageSwitcherTile(),
        const Divider(),

        // Reading Progress
        ListTile(
          leading: const Icon(Icons.analytics_outlined),
          title: Text(l10n['reading_progress']),
          subtitle: Text(l10n['view_reading_stats']),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadingProgressScreen()),
            );
          },
        ),
        const Divider(),

        // Delete Account
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red[900]),
          title: Text(
            l10n['deleteAccount'],
            style: TextStyle(color: Colors.red[900]),
          ),
          subtitle: Text(l10n['deleteAccountDescription']),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[900]),
          onTap: () => _showDeleteAccountDialog(context, authProvider, l10n),
        ),
        const Divider(),

        // Logout
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            l10n['logout'],
            style: TextStyle(color: Colors.red[700]),
          ),
          subtitle: Text(l10n['sign_out_description']),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[700]),
          onTap: () => _showLogoutDialog(context, authProvider, l10n),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n['logout']),
        content: Text(l10n['logout_confirmation']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n['cancel']),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n['logged_out_successfully'])),
                );
              }
            },
            child: Text(
              l10n['logout'],
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return DeleteAccountDialog(
            isLoading: provider.isLoading,
            onConfirm: () async {
              final success = await authProvider.deleteAccount();

              if (context.mounted) {
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n['accountDeletedSuccessfully']),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Navigate to login screen after successful deletion
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n['deleteAccountFailed']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'free_user':
        return 'Free User';
      case 'paid_user':
        return 'Premium User';
      case 'admin':
        return 'Administrator';
      case 'owner':
        return 'Owner';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}