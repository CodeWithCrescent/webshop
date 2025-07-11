import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final items = [
      TabItem(icon: Icons.home, title: loc.translate('menu.home')),
      TabItem(icon: Icons.inventory_2_outlined, title: loc.translate('menu.inventory')),
      TabItem(icon: Icons.add, title: loc.translate('menu.cash_sales')),
      TabItem(icon: Icons.people_alt_outlined, title: loc.translate('menu.customers')),
      TabItem(icon: Icons.bar_chart, title: loc.translate('menu.z_reports')),
    ];

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
