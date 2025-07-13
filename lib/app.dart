import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:webshop/modules/auth/splash_page.dart';
import 'package:webshop/modules/customers/pages/customers_page.dart';
import 'package:webshop/modules/dashboard/dashboard_page.dart';
import 'package:webshop/modules/inventory/pages/inventory_page.dart';
import 'package:webshop/modules/sales/pages/sales_page.dart';
import 'package:webshop/modules/settings/pages/business_profile_page.dart';
import 'package:webshop/shared/layout_page.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'modules/auth/login_page.dart';
import 'modules/receipts/pages/receipts_page.dart';
import 'modules/zreport/zreports_page.dart';

class WebShopApp extends StatelessWidget {
  WebShopApp({super.key});

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeMode == ThemeMode.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;

        // Set status bar color to match AppBar color
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: theme.appBarTheme.backgroundColor ?? Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'WebSHOP',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/login',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/layout': (context) => const LayoutPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/inventory': (context) => const InventoryPage(),
            '/business-profile': (context) => const BusinessProfilePage(),
            '/customers': (context) => const CustomersPage(),
            '/receipts': (context) => const ReceiptsPage(),
            '/z-reports': (context) => const ZReportsPage(),
            '/sales': (context) => const SalesPage(),
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}
