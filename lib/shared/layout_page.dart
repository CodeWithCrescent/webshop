import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/customers/pages/customer_modal.dart';
import 'package:webshop/modules/customers/pages/customers_page.dart';
import 'package:webshop/modules/customers/providers/customer_provider.dart';
import 'package:webshop/modules/dashboard/dashboard_page.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import 'package:webshop/modules/inventory/pages/inventory_page.dart';
import 'package:webshop/modules/sales/pages/sales_page.dart';
import 'package:webshop/modules/inventory/pages/product_modal.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/settings/pages/profile_page.dart';
import 'package:webshop/shared/providers/auth_provider.dart';
import 'package:webshop/shared/widgets/bottom_bar.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const InventoryPage(),
    const Placeholder(),
    const CustomersPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!authProvider.isAuthenticated) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locInventory = InventoryLocalizations(context);

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomBar(
        selectedIndex: _currentIndex,
        onTap: (index) => _onTabTapped(context, index, loc, locInventory),
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index, AppLocalizations? loc,
      InventoryLocalizations locInventory) {
    if (index == 2) {
      _showActionSheet(context, loc, locInventory);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showActionSheet(BuildContext context, AppLocalizations? loc,
      InventoryLocalizations locInventory) {
    List<Widget> actions = [];

    switch (_currentIndex) {
      case 0: // Home
      case 4: // Profile
        actions = [
          _buildActionTile(
            loc?.translate('dashboard.cash_sales') ?? 'Cash Sales',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesPage(),
                ),
              );
            },
          ),
          _buildActionTile(
            loc?.translate('dashboard.create_invoice') ?? 'Create Invoice',
          ),
          _buildDivider(),
          _buildCancelTile(loc),
        ];
        break;
      case 1: // Inventory
        actions = [
          _buildActionTile(
            locInventory.addProduct,
            onTap: () {
              Navigator.pop(context);
              _showAddProductModal(context);
            },
          ),
          _buildDivider(),
          _buildCancelTile(loc),
        ];
        break;
      case 3: // Customers
        actions = [
          _buildActionTile(
            loc?.translate('customers.add_customer') ?? 'Add Customer',
            onTap: () {
              Navigator.pop(context);
              _showAddCustomerModal(context);
            },
          ),
          _buildDivider(),
          _buildCancelTile(loc),
        ];
        break;
      default:
        actions = [_buildCancelTile(loc)];
    }

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Wrap(children: actions),
    );
  }

  void _showAddCustomerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomerModal(
        onSuccess: () {
          context.read<CustomerProvider>().getCustomers();
        },
      ),
    );
  }

  void _showAddProductModal(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductModal(
        product: product,
        onSuccess: () {
          context.read<InventoryProvider>().loadProducts();
        },
      ),
    );
  }

  Widget _buildActionTile(String title, {Function()? onTap}) => ListTile(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondary),
        ),
        onTap: onTap ?? () {},
      );

  Widget _buildCancelTile(AppLocalizations? loc) => ListTile(
        title: Text(
          loc?.translate('common.cancel') ?? 'Cancel',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        onTap: () => Navigator.pop(context),
      );

  Widget _buildDivider() => const Divider(height: 1);
}
