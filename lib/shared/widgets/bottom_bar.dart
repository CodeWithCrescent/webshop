import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:webshop/core/constants/app_colors.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  static const List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.inventory_2_outlined, title: 'Inventory'),
    TabItem(icon: Icons.add, title: 'Cash Sales'),
    TabItem(icon: Icons.people_alt_outlined, title: 'Customers'),
    TabItem(icon: Icons.bar_chart, title: 'Z-Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomBarCreative(
      items: items,
      backgroundColor: AppColors.surfaceLight,
      color: AppColors.textSecondary,
      colorSelected: AppColors.primary,
      indexSelected: selectedIndex,
      iconSize: 24,
      isFloating: true,
      highlightStyle: const HighlightStyle(
        sizeLarge: true,
        background: AppColors.primary,
        elevation: 4,
      ),
      onTap: onTap,
    );
  }
}
