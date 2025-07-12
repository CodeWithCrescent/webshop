import 'package:flutter/material.dart';
import 'package:webshop/modules/settings/pages/business_profile_page.dart';
import 'package:webshop/modules/settings/pages/user_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Business'),
            Tab(text: 'User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BusinessProfilePage(),
          UserProfilePage(),
        ],
      ),
    );
  }
}