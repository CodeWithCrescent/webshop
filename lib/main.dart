import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/modules/customers/data/local/customer_local_datasource.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import 'package:webshop/modules/customers/providers/customer_provider.dart';
import 'package:webshop/modules/inventory/data/local/product_local_datasource.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/receipts/providers/receipt_provider.dart';
import 'package:webshop/modules/sales/providers/sales_provider.dart';
import 'package:webshop/modules/settings/data/local/business_profile_local_data_source.dart';
import 'package:webshop/modules/settings/models/business_profile.dart';
import 'package:webshop/modules/settings/providers/business_profile_provider.dart';
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
  await _init();
}

Future<void> _init() async {
  await AppLocalizations.init();
  final prefs = await SharedPreferences.getInstance();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(BusinessProfileAdapter());

  // Open Hive boxes
  final productBox = await Hive.openBox<Product>('products');
  final categoryBox = await Hive.openBox<Category>('categories');
  final customerBox = await Hive.openBox<Customer>('customers');
  final businessProfileBox =
      await Hive.openBox<BusinessProfile>('business_profile');

  // Create HTTP client
  final httpClient = HttpClient(prefs: prefs, navigatorKey: navigatorKey);

  // Create providers
  final authProvider = AuthProvider();
  final businessProfileProvider = BusinessProfileProvider(
    httpClient: httpClient,
    localDataSource: BusinessProfileLocalDataSource(
      businessProfileBox: businessProfileBox,
    ),
  );

  // Set up the callbacks
  authProvider.setCallbacks(
    onLoginSuccess: () async {
      await businessProfileProvider.fetchBusinessProfile();
    },
    onLogout: () async {
      await businessProfileProvider.clearProfile();
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(prefs, httpClient),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(
            localDataSource: ProductLocalDataSource(
              productBox: productBox,
              categoryBox: categoryBox,
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => businessProfileProvider),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            httpClient: httpClient,
            localDataSource: CustomerLocalDataSource(customerBox: customerBox),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider(httpClient: httpClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ZReportProvider(httpClient: httpClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(
            httpClient: httpClient,
            businessProfileProvider: businessProfileProvider,
          ),
        ),
      ],
      child: WebShopApp(),
    ),
  );
}
