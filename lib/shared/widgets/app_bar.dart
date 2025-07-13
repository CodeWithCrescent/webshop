import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webshop/core/constants/app_colors.dart';

class WebshopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final bool centerTitle;
  final VoidCallback? onRefresh;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? appBarHeight;

  const WebshopAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.onRefresh,
    this.actions,
    this.bottom,
    this.appBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight ?? kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: title is String
              ? Text(
                  title,
                  style: const TextStyle(color: AppColors.textLight),
                )
              : title as Widget,
          centerTitle: centerTitle,
          titleTextStyle: const TextStyle(
            color: AppColors.textLight,
            fontSize: 22,
          ),
          iconTheme: const IconThemeData(color: AppColors.textLight),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: actions != null && actions!.isNotEmpty
              ? actions
              : onRefresh != null
                  ? [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: onRefresh,
                        tooltip: 'Refresh',
                      ),
                    ]
                  : [const SizedBox()],
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? kToolbarHeight);
}
