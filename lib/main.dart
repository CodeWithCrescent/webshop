import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'modules/dashboard/dashboard_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await  _init();
}

Future<void> _init() async {
  await AppLocalizations.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(prefs)),
      ],
      child: const WebShopApp(),
    ),
  );
}

