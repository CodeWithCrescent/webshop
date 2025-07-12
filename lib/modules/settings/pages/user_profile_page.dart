import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/shared/providers/auth_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<Map<String, String?>> _userPrefsFuture;

  @override
  void initState() {
    super.initState();
    _userPrefsFuture = _loadUserPrefs();
  }

  Future<Map<String, String?>> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? 'Guest',
      'email': prefs.getString('email') ?? 'guest@webshop.co.tz',
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<Map<String, String?>>(
        future: _userPrefsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = snapshot.data!['name']!;
          final email = snapshot.data!['email']!;

          return Column(
            children: [
              WebshopAppBar(
                title: loc?.translate('settings.user_profile') ?? 'User Profile',
                onRefresh: () => setState(() {
                  _userPrefsFuture = _loadUserPrefs();
                }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // User Profile Card
                      _buildProfileCard(context, name, email),
                      
                      const SizedBox(height: 24),
                      
                      // User Information Section
                      _buildUserInfoSection(context, name, email),
                      
                      // Spacer to push logout button down
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Logout Button
              _buildLogoutButton(context, authProvider),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, String name, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionHeader(
          context,
          'Personal Information',
          Icons.person_outline,
        ),
        _buildInfoItem(
          context,
          'Full Name',
          name,
          Icons.badge,
        ),
        _buildInfoItem(
          context,
          'Email Address',
          email,
          Icons.email,
        ),
        
        // App Settings
        _buildSectionHeader(
          context,
          'App Settings',
          Icons.settings,
        ),
        _buildInfoItem(
          context,
          'Language',
          'English', // You can make this dynamic
          Icons.language,
        ),
        _buildInfoItem(
          context,
          'Theme',
          'System Default', // You can make this dynamic
          Icons.color_lens,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await authProvider.logout();
            navigator.pushReplacementNamed('/login');
          },
        ),
      ),
    );
  }
}