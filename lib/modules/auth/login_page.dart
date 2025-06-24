import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/gradient_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight.withOpacity(0.95),
              AppColors.backgroundLight.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const AppLogo(size: 80),
                  const SizedBox(height: 32),
                  
                  // Login form card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: const _LoginForm(),
                  ),
                  
                  // Footer
                  const SizedBox(height: 32),
                  Text(
                    'WebSHOP ZTL v2.0',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loc = AppLocalizations.of(context);
           
    // Map raw error to localized message
    String getFriendlyError(String error) {
      final lowerError = error.toLowerCase();

      // Connection or network-related errors
      if (lowerError.contains('socketexception') ||
          lowerError.contains('handshakeexception') ||
          lowerError.contains('failed host lookup') ||
          lowerError.contains('timeout') ||
          lowerError.contains('network') ||
          lowerError.contains('connection') ||
          lowerError.contains('unable to connect')) {
        return loc!.translate('network_error');
      }

      else if (lowerError.contains('dieexception') ||
              lowerError.contains('auth') ||
              lowerError.contains('unauthorized')) {
        return loc!.translate('login_error');
      } else if (lowerError.contains('invalid credentials') ||
          lowerError.contains('invalid username') ||
          lowerError.contains('invalid password')) {
        return loc!.translate('invalid_credentials');
      } else if (lowerError.contains('user not found') ||
                 lowerError.contains('no user found')) {
        return loc!.translate('user_not_found');
      } else if (lowerError.contains('server error') ||
                 lowerError.contains('internal server error')) {
        return loc!.translate('server_error');
      }

      // Fallback
      return error;
    }

    if (authProvider.isAuthenticated) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/dashboard'));
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            loc!.translate('login_title'),
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('login_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Inside your widget tree
          if (authProvider.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getFriendlyError(authProvider.error!),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (authProvider.error != null)
            const SizedBox(height: 16),
          
          // Username field
          Text(
            loc.translate('username'),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: loc.translate('username_hint'),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.translate('validation_required');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Password field
          Text(
            loc.translate('password'),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: loc.translate('password_hint'),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.translate('validation_required');
              }
              if (value.length < 6) {
                return loc.translate('validation_password_length');
              }
              return null;
            },
          ),
          // const SizedBox(height: 16),
          
          // // Remember me & Forgot password
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         Checkbox(
          //           value: true,
          //           onChanged: (value) {},
          //           activeColor: AppColors.primary,
          //         ),
          //         Text(
          //           loc.translate('remember_me'),
          //           style: AppTextStyles.bodyMedium,
          //         ),
          //       ],
          //     ),
          //     TextButton(
          //       onPressed: () {},
          //       child: Text(
          //         loc.translate('forgot_password'),
          //         style: AppTextStyles.bodyMedium.copyWith(
          //           color: AppColors.primary,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 32),
          
          // Login button
          GradientButton(
            width: double.infinity,
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await authProvider.login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      } catch (e) {
                        // Error is already handled in provider
                      }
                    }
                  },
            gradient: AppColors.primaryGradient,
            child: authProvider.isLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                : Text(
                    loc.translate('login_button'),
                    style: AppTextStyles.buttonTextLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}