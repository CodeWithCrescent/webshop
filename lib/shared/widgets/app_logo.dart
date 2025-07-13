import 'package:flutter/material.dart';
import 'package:webshop/core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 4,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.backgroundLight, AppColors.backgroundLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.backgroundLight.withOpacity(0.4),
        //     blurRadius: 15,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo-1.png',
          // width: size * 0.6,
          height: size * 0.6,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
