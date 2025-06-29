import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('sw'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedStrings = {};

  /// Load and flatten all language JSON files
  static Future<void> init() async {
    await loadStrings('en');
    await loadStrings('sw');
  }

  static Future<void> loadStrings(String langCode) async {
    final jsonString = await rootBundle.loadString('assets/l10n/$langCode.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings[langCode] = _flattenJson(jsonMap);
  }

  /// Recursively flatten nested JSON into dot.notation keys
  static Map<String, String> _flattenJson(Map<String, dynamic> json, [String prefix = '']) {
    final Map<String, String> result = {};

    json.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is String) {
        result[newKey] = value;
      } else if (value is Map<String, dynamic>) {
        result.addAll(_flattenJson(value, newKey));
      }
    });

    return result;
  }

  /// Retrieve the translation using dot.notation key
  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)!.translate(key);
}
