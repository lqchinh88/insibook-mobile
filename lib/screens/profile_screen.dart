import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../lang/app_localizations.dart';
import '../widgets/language_switcher_tile.dart';
import '../widgets/theme_toggle_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n['profile'] ?? 'Profile'),
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
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile Information
                    _buildInfoSection(context, user, l10n),
                    
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

  Widget _buildInfoSection(BuildContext context, user, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, l10n['name'] ?? 'Name', user.fullName, l10n),
            _buildInfoRow(Icons.email, l10n['email'] ?? 'Email', user.email, l10n),
            _buildInfoRow(Icons.verified_user, 'Role', _formatRole(user.role), l10n),
            _buildInfoRow(
              Icons.calendar_today, 
              'Member since', 
              _formatDate(user.createdAt),
              l10n,
            ),
            if (user.isAdmin)
              _buildInfoRow(Icons.admin_panel_settings, 'Status', 'Administrator', l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    return Column(
      children: [
        // Refresh Profile
        ListTile(
          leading: const Icon(Icons.refresh),
          title: Text(l10n['refresh_profile'] ?? 'Refresh Profile'),
          subtitle: Text(l10n['refresh_profile_description'] ?? 'Update your profile information'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            // Show loading and refresh profile
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n['refreshing_profile'] ?? 'Refreshing profile...')),
            );
            await authProvider.initialize();
          },
        ),
        const Divider(),
        
        // Settings (placeholder)
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(l10n['settings'] ?? 'Settings'),
          subtitle: Text(l10n['settings_description'] ?? 'App preferences and notifications'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n['settings_coming_soon'] ?? 'Settings coming soon!')),
            );
          },
        ),
        const Divider(),
        
        // Theme Toggle
        const ThemeSettingsTile(),
        const Divider(),

        // Language Switcher
        const LanguageSwitcherTile(),
        const Divider(),
        
        // Logout
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            l10n['logout'] ?? 'Logout',
            style: TextStyle(color: Colors.red[700]),
          ),
          subtitle: Text(l10n['sign_out_description'] ?? 'Sign out of your account'),
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
        title: Text(l10n['logout'] ?? 'Logout'),
        content: Text(l10n['logout_confirmation'] ?? 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n['logged_out_successfully'] ?? 'Logged out successfully')),
                );
              }
            },
            child: Text(
              l10n['logout'] ?? 'Logout',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
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