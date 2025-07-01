import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class AuthLocalizations {
  final BuildContext context;

  AuthLocalizations(this.context);

  String get title => _translate('auth.title');
  String get subtitle => _translate('auth.subtitle');
  String get username => _translate('auth.username');
  String get usernameHint => _translate('auth.username_hint');
  String get password => _translate('auth.password');
  String get passwordHint => _translate('auth.password_hint');
  String get button => _translate('auth.button');
  String get rememberMe => _translate('auth.remember_me');
  String get forgotPassword => _translate('auth.forgot_password');
  String get showPassword => _translate('auth.show_password');
  String get hidePassword => _translate('auth.hide_password');
  String get signInWith => _translate('auth.sign_in_with');

  // Common validation
  String get validationRequired => _translate('auth.validation_required_field');
  String get validationPasswordLength => _translate('auth.validation_password_length');

  // Errors
  String get errorRequired => _translate('auth.error.required');
  String get errorPasswordLength => _translate('auth.error.password_length');
  String get errorLoginFailed => _translate('auth.error.login_failed');
  String get errorInvalidCredentials => _translate('auth.error.invalid_credentials');
  String get errorNetwork => _translate('auth.error.network');
  String get errorServer => _translate('auth.error.server');

  String _translate(String key) {
    return AppLocalizations.of(context)!.translate(key);
  }
}
