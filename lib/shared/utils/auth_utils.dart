import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/shared/providers/auth_provider.dart';

/// Checks if the user's session is valid.
/// If not authenticated, performs logout and redirects to login.
Future<void> checkAndRedirectAuth(BuildContext context) async {
  final authProvider = context.read<AuthProvider>();
  await authProvider.checkAuthStatus();

  if (!authProvider.isAuthenticated) {
    await authProvider.logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/login',
        arguments: {
          'message': "Your session has expired. Please log in again.",
          'messageType': 'error'
        },
      );
    }
  }
}
