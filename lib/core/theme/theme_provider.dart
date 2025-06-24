import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  final SharedPreferences prefs;
  static const String _themeKey = 'theme_mode';

  ThemeProvider(this.prefs) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = prefs.getString(_themeKey);
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }
}
