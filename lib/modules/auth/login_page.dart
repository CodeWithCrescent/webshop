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
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (authProvider.isAuthenticated) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/layout'));
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
              prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurface),
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
            obscureText: true,
            decoration: InputDecoration(
              hintText: loc.translate('auth.password_hint'),
              prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurface),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.translate('auth.validation_required_field');
              }
              return null;
            },
          ),
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
