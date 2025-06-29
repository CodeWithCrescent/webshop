import 'package:flutter/material.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/dashboard/dashboard_page.dart';
import 'package:webshop/modules/inventory/pages/inventory_page.dart';
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
    // CustomersPage(),
    // ZReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomBar(
        selectedIndex: _currentIndex,
        onTap: (index) => _onTabTapped(context, index, loc),
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index, AppLocalizations? loc) {
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                title: Text(
                  loc?.translate('dashboard.cash_sales') ?? 'Cash Sales',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('dashboard.register_customer') ?? 'Register Customer',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('dashboard.create_invoice') ?? 'Create Invoice',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('common.cancel') ?? 'Cancel',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}