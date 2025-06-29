import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<Widget>? actions;

  const ModalHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
            onPressed: onClose,
          ),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: actions ?? [const SizedBox(width: 48)],
          ),
        ],
      ),
    );
  }
}