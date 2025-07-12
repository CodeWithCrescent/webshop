import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webshop/core/constants/app_colors.dart';

class WebshopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRefresh;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const WebshopAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            title,
            style: const TextStyle(color: AppColors.textLight),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.textLight,
            fontSize: 22,
          ),
          iconTheme: const IconThemeData(color: AppColors.textLight),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: actions != null && actions!.isNotEmpty
              ? actions
              : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                  ),
                ],
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
