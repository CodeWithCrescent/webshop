import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/modules/customers/data/local/customer_local_datasource.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import 'package:webshop/modules/customers/providers/customer_provider.dart';
import 'package:webshop/modules/inventory/data/local/product_local_datasource.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/settings/providers/company_profile_provider.dart';
import 'package:webshop/modules/zreport/providers/zreport_provider.dart';
import 'app.dart';
import 'modules/dashboard/dashboard_provider.dart';
import 'modules/inventory/models/product.dart';
import 'modules/inventory/models/category.dart';
import 'shared/providers/auth_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/theme_provider.dart';
import 'core/network/http_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerReceiptHtmlView();
  await _init();
}

void registerReceiptHtmlView() {
  const platform = MethodChannel('receipt_html');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'create') {
      return _createReceiptView(call.arguments as int);
    }
    return null;
  });
}

int _createReceiptView(int id) {
  // This is to be implemented in platform-specific code
  // (Android/iOS) to create a WebView for the receipt
  return id;
}

Future<void> _init() async {
  await AppLocalizations.init();
  final prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CustomerAdapter());

  // Open Hive boxes
  final productBox = await Hive.openBox<Product>('products');
  final categoryBox = await Hive.openBox<Category>('categories');
  final customerBox = await Hive.openBox<Customer>('customers');

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
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            httpClient: httpClient,
            localDataSource: CustomerLocalDataSource(customerBox: customerBox),
          ),
        ),
        // ChangeNotifierProvider(create: (_) => ReceiptProvider(httpClient: httpClient)),
        ChangeNotifierProvider(
          create: (_) => ZReportProvider(httpClient: httpClient),
        ),
      ],
      child: const WebShopApp(),
    ),
  );
}
