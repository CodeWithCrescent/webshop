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
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cardLight.withOpacity(0.25),
              AppColors.primary.withOpacity(0.1),
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
                      color: AppColors.cardLight.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: _LoginForm(initialError: routeArgs?['error']),
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
  final String? initialError;
  const _LoginForm({this.initialError});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setError(widget.initialError!);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Map raw error to localized message
    String getFriendlyError(String error) {
      final lowerError = error.toLowerCase();

      print(lowerError);

      // Connection or network-related errors
      if (lowerError.contains('socketexception') ||
          lowerError.contains('handshakeexception') ||
          lowerError.contains('failed host lookup') ||
          lowerError.contains('timeout') ||
          lowerError.contains('network') ||
          lowerError.contains('connection') ||
          lowerError.contains('unable to connect')) {
        return loc.translate('auth.error.network');
      } else if (lowerError.contains('dieexception') ||
          lowerError.contains('auth') ||
          lowerError.contains('unauthorized')) {
        return loc.translate('auth.error.login_failed');
      } else if (lowerError.contains('invalid credentials') ||
          lowerError.contains('invalid username') ||
          lowerError.contains('invalid password')) {
        return loc.translate('auth.error.invalid_credentials');
      } else if (lowerError.contains('user not found') ||
          lowerError.contains('no user found')) {
        return loc.translate('auth.error.login_failed');
      } else if (lowerError.contains('server error') ||
          lowerError.contains('internal server error')) {
        return loc.translate('auth.error.server');
      }

      // Fallback
      return error;
    }

    if (authProvider.isAuthenticated) {
      Future.microtask(
        () => Navigator.pushReplacementNamed(context, '/layout'),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('auth.title'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('auth.subtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          if (authProvider.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getFriendlyError(authProvider.error!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (authProvider.error != null) const SizedBox(height: 16),

          // Username
          Text(
            loc.translate('auth.username'),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: loc.translate('auth.username_hint'),
              prefixIcon: Icon(
                Icons.person_outline,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.translate('auth.validation_required_field');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password
          Text(
            loc.translate('auth.password'),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: loc.translate('auth.password_hint'),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colorScheme.onSurface,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                tooltip: _obscureText
                    ? loc.translate('auth.show_password')
                    : loc.translate('auth.hide_password'),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.translate('auth.validation_required_field');
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
          //           loc.translate('auth.remember_me'),
          //           style: AppTextStyles.bodyMedium,
          //         ),
          //       ],
          //     ),
          //     TextButton(
          //       onPressed: () {},
          //       child: Text(
          //         loc.translate('auth.forgot_password'),
          //         style: AppTextStyles.bodyMedium.copyWith(
          //           color: AppColors.primary,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 32),

          // Login Button
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
                      } catch (_) {}
                    }
                  },
            gradient: AppColors.primaryGradient,
            child: authProvider.isLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                : Text(
                    loc.translate('auth.button'),
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
