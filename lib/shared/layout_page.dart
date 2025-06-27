import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
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
    );
  }

  void _onTabTapped(BuildContext context, int index, AppLocalizations? loc) {
    if (index == 2) {
      showAdaptiveActionSheet(
        context: context,
        actions: <BottomSheetAction>[
          BottomSheetAction(
            title: const Text('Item 1'),
            onPressed: (_) => Navigator.of(context).pop(),
          ),
          BottomSheetAction(
            title: const Text('Item 2'),
            onPressed: (_) => Navigator.of(context).pop(),
          ),
          BottomSheetAction(
            title: const Text('Item 3'),
            onPressed: (_) => Navigator.of(context).pop(),
          ),
        ],
        cancelAction: CancelAction(title: Text(loc!.translate('cancel'))),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}