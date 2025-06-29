import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
      onChanged: onChanged,
    );
  }
}