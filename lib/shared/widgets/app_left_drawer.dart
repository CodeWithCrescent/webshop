import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/modules/settings/pages/company_profile_page.dart';
import 'package:webshop/shared/providers/auth_provider.dart';

class AppLeftDrawer extends StatelessWidget {
  const AppLeftDrawer({super.key});

  Future<Map<String, String?>> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? 'Guest',
      'email': prefs.getString('email') ?? 'guest@webshop.co.tz',
    };
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: FutureBuilder<Map<String, String?>>(
        future: _loadUserPrefs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = snapshot.data!['name']!;
          final email = snapshot.data!['email']!;

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                accountName: Text(
                  name,
                  style: const TextStyle(fontSize: 16),
                ),
                accountEmail: Text(
                  email,
                  style: const TextStyle(fontSize: 14),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Company Profile'),
                onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CompanyProfilePage()),
                    );
                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await authProvider.logout();
                  navigator.pop();
                  navigator.pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
