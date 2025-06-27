import 'package:flutter/material.dart';
import 'package:webshop/modules/dashboard/dashboard_page.dart';
import 'package:webshop/shared/widgets/bottom_bar.dart';
import '../../../core/localization/app_localizations.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    // InventoryPage(),
    const Placeholder(),
    // CustomersPage(),
    // ZReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomBar(
        selectedIndex: _currentIndex,
        onTap: (index) => _onTabTapped(context, index, loc),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                accountName: Text(
                  "Zalongwa User",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text("ztl@gmail.com"),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    "Z",
                    style: TextStyle(fontSize: 30.0, color: Colors.blue),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text(' Edit Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
                  loc?.translate('cash_sales') ?? 'Cash Sales',
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('register_customer') ?? 'Register Customer',
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('create_invoice') ?? 'Create Invoice',
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  loc?.translate('cancel') ?? 'Cancel',
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