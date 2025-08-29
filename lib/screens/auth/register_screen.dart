import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../lang/app_localizations.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _getErrorMessage(AuthState state, AppLocalizations l10n) {
    switch (state) {
      case AuthState.loginFailedInvalidCredentials:
        return l10n['invalid_email_password'];
      case AuthState.loginFailedNetworkError:
        return l10n['network_error'];
      case AuthState.registerFailedEmailExists:
        return l10n['email_already_registered'];
      case AuthState.registerFailedNetworkError:
        return l10n['network_error'];
      case AuthState.initializationFailed:
        return l10n['failed_to_initialize'];
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearState();

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
    );

    if (success && mounted) {
      // Registration successful - pop back to previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n['sign_up'] ?? 'Sign Up'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Logo/Title
                Icon(
                  Icons.book,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n['create_account'] ?? 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  l10n['join_message'] ?? 'Join InsiBook to get personalized book summaries',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Name fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n['first_name'] ?? 'First Name',
                          hintText: l10n['john_doe_example'] ?? 'John',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n['last_name'] ?? 'Last Name',
                          hintText: l10n['doe_example'] ?? 'Doe',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n['email'] ?? 'Email',
                    hintText: l10n['email_example'] ?? 'john.doe@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n['please_enter_email'] ?? 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return l10n['please_enter_valid_email'] ?? 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n['password'] ?? 'Password',
                    hintText: l10n['at_least_6_chars'] ?? 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n['please_enter_password'] ?? 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return l10n['password_min_length'] ?? 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    labelText: l10n['confirm_password'] ?? 'Confirm Password',
                    hintText: l10n['reenter_password'] ?? 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n['please_confirm_password'] ?? 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return l10n['passwords_do_not_match'] ?? 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final errorMessage = _getErrorMessage(authProvider.authState, l10n);
                    if (errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                // Register button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n['create_account'] ?? 'Create Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n['already_have_account'] ?? 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l10n['sign_in'] ?? 'Sign In',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          ),
        );
      },
    );
  }
}