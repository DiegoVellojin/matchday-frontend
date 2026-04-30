import 'package:flutter/material.dart';

class MatchDaySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const MatchDaySearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          icon: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.search,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
