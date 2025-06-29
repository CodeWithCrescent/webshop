import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:webshop/modules/dashboard/dashboard_page.dart';
import 'package:webshop/modules/inventory/inventory_page.dart';
import 'package:webshop/shared/layout_page.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'modules/auth/login_page.dart';
import 'shared/widgets/glass_container.dart';

class WebShopApp extends StatelessWidget {
  const WebShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WebSHOP',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/layout': (context) => const LayoutPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/inventory': (context) => const InventoryPage(),
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return GlassContainer(
              child: child!,
            );
          },
        );
      },
    );
  }
}