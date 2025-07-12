import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/settings/pages/business_profile_page.dart';
import 'package:webshop/modules/settings/pages/user_profile_page.dart';
import 'package:webshop/shared/utils/auth_utils.dart';
import 'package:webshop/shared/widgets/app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndRedirectAuth(context);
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('settings.profile') ?? 'Profile',
        appBarHeight: 96,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Business'),
              Tab(text: 'User'),
            ],
          ),
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