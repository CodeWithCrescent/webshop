import 'package:flutter/material.dart';
import 'package:webshop/core/constants/app_colors.dart';

class AppLeftDrawer extends StatelessWidget {
  const AppLeftDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: UserAccountsDrawerHeader(
              accountName: Text(
                "Zalongwa User",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              accountEmail: Text("ztl@gmail.com",
                style: TextStyle(fontSize: 14, color: Colors.white),),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(' Company Profile '),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}