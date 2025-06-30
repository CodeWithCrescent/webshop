import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/modules/inventory/data/local/product_local_datasource.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/settings/providers/company_profile_provider.dart';
import 'app.dart';
import 'modules/dashboard/dashboard_provider.dart';
import 'modules/inventory/models/product.dart';
import 'modules/inventory/models/category.dart';
import 'shared/providers/auth_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/theme_provider.dart';
import 'core/network/http_client.dart';// Add if you have z-reports

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _init();
}

Future<void> _init() async {
  await AppLocalizations.init();
  final prefs = await SharedPreferences.getInstance();
  
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CategoryAdapter());
  
  // Open Hive boxes
  final productBox = await Hive.openBox<Product>('products');
  final categoryBox = await Hive.openBox<Category>('categories');

  // Create HTTP client
  final httpClient = HttpClient(prefs: prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(
            localDataSource: ProductLocalDataSource(
              productBox: productBox,
              categoryBox: categoryBox,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CompanyProfileProvider(httpClient: httpClient),
        ),
        // ChangeNotifierProvider(create: (_) => CustomerProvider(httpClient: httpClient)),
        // ChangeNotifierProvider(create: (_) => ReceiptProvider(httpClient: httpClient)),
        // ChangeNotifierProvider(create: (_) => ZReportProvider(httpClient: httpClient)),
      ],
      child: const WebShopApp(),
    ),
  );
}