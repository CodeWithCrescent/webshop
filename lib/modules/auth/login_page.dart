import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/constants/app_text_styles.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/shared/providers/auth_provider.dart';
import 'package:webshop/shared/widgets/app_logo.dart';
import 'package:webshop/shared/widgets/gradient_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 55),
                  const SizedBox(height: 40),
                  _buildLoginFormCard(context, routeArgs),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cardLight.withOpacity(0.25),
          AppColors.primary.withOpacity(0.1),
        ],
      ),
    );
  }

  Widget _buildLoginFormCard(BuildContext context, Map<String, dynamic>? routeArgs) {
    return Container(
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
    );
  }

  Widget _buildFooter() {
    return Text(
      'WebSHOP ZTL v2.0',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
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
  bool _snackBarShown = false;

  @override
  void initState() {
    super.initState();
    _handleInitialError();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleRouteMessage();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleInitialError() {
    if (widget.initialError != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setError(widget.initialError!);
    }
  }

  void _handleRouteMessage() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final message = args?['message'] as String?;
    final messageType = args?['messageType'] as String?;

    if (!_snackBarShown && message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(
          context,
          message,
          isError: messageType == 'error',
        );
        _resetSnackBarState();
      });
    }
  }

  void _resetSnackBarState() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.error != null) {
          authProvider.clearError();
        }
        _snackBarShown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _handleAuthStateChanges(context, authProvider);
        _handleAuthErrors(context, authProvider);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildUsernameField(context),
              const SizedBox(height: 24),
              _buildPasswordField(context),
              const SizedBox(height: 32),
              _buildLoginButton(context, authProvider),
            ],
          ),
        );
      },
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/layout');
      });
    }
  }

  void _handleAuthErrors(BuildContext context, AuthProvider authProvider) {
    if (!_snackBarShown && authProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final loc = AppLocalizations.of(context)!;
        final error = _getFriendlyError(loc, authProvider.error!);
        
        _showSnackBar(context, error, isError: true);
        _snackBarShown = true;
        _scheduleErrorClear(authProvider);
      });
    }
  }

  void _scheduleErrorClear(AuthProvider authProvider) {
    Future.delayed(const Duration(seconds: 5), () {
      if (authProvider.error != null) {
        authProvider.clearError();
        _snackBarShown = false;
      }
    });
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('auth.title'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.translate('auth.subtitle'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('auth.username'),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: _buildInputDecoration(
            context,
            hintText: loc.translate('auth.username_hint'),
            icon: Icons.person_outline,
          ),
          validator: (value) => _validateRequiredField(value, loc),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('auth.password'),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          decoration: _buildInputDecoration(
            context,
            hintText: loc.translate('auth.password_hint'),
            icon: Icons.lock_outline,
            isPassword: true,
            onToggleVisibility: _togglePasswordVisibility,
            visibilityTooltip: _obscureText
                ? loc.translate('auth.show_password')
                : loc.translate('auth.hide_password'),
          ),
          validator: (value) => _validateRequiredField(value, loc),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    String? visibilityTooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: colorScheme.onSurface,
        size: 20,
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurface.withOpacity(0.7),
                size: 20,
              ),
              onPressed: onToggleVisibility,
              tooltip: visibilityTooltip,
            )
          : null,
    );
  }

  String? _validateRequiredField(String? value, AppLocalizations loc) {
    if (value == null || value.isEmpty) {
      return loc.translate('auth.validation_required_field');
    }
    return null;
  }

  Widget _buildLoginButton(BuildContext context, AuthProvider authProvider) {
    final loc = AppLocalizations.of(context)!;

    return GradientButton(
      width: double.infinity,
      onPressed: authProvider.isLoading
          ? null
          : () => _handleLogin(context, authProvider),
      gradient: AppColors.primaryGradient,
      child: authProvider.isLoading
          ? const SpinKitThreeBounce(color: Colors.white, size: 20)
          : Text(
              loc.translate('auth.button'),
              style: AppTextStyles.buttonTextLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Future<void> _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );
      } catch (_) {
        // Error handling is done through the provider state
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String _getFriendlyError(AppLocalizations loc, String error) {
    final lowerError = error.toLowerCase();

    if (_isNetworkError(lowerError)) {
      return loc.translate('auth.error.network');
    } else if (_isAuthError(lowerError)) {
      return loc.translate('auth.error.login_failed');
    } else if (_isInvalidCredentialsError(lowerError)) {
      return loc.translate('auth.error.invalid_credentials');
    } else if (_isUserNotFoundError(lowerError)) {
      return loc.translate('auth.error.login_failed');
    } else if (_isServerError(lowerError)) {
      return loc.translate('auth.error.server');
    }

    return error;
  }

  bool _isNetworkError(String error) => error.contains('socketexception') ||
      error.contains('handshakeexception') ||
      error.contains('failed host lookup') ||
      error.contains('timeout') ||
      error.contains('network') ||
      error.contains('connection') ||
      error.contains('unable to connect');

  bool _isAuthError(String error) =>
      error.contains('dieexception') ||
      error.contains('auth') ||
      error.contains('unauthorized');

  bool _isInvalidCredentialsError(String error) =>
      error.contains('invalid credentials') ||
      error.contains('invalid username') ||
      error.contains('invalid password');

  bool _isUserNotFoundError(String error) =>
      error.contains('user not found') || error.contains('no user found');

  bool _isServerError(String error) =>
      error.contains('server error') || error.contains('internal server error');
}