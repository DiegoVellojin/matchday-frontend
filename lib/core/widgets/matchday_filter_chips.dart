import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MatchDayFilterChips<T> extends StatelessWidget {
  final List<FilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;
  final VoidCallback? onAdvancedFiltersPressed;

  const MatchDayFilterChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.onAdvancedFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: options.length + (onAdvancedFiltersPressed != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == options.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ActionChip(
                backgroundColor: colorScheme.surface,
                side: BorderSide(
                  color: isDark ? AppColors.border : Colors.grey.shade300,
                ),
                label: Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Text('Filtros', style: TextStyle(color: colorScheme.onSurface)),
                  ],
                ),
                onPressed: onAdvancedFiltersPressed,
              ),
            );
          }

          final option = options[index];
          final isSelected = selectedValue == option.value;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: colorScheme.surface,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.transparent : Colors.grey.shade300),
              ),
              label: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onSelected: (selected) {
                onSelected(option.value);
              },
            ).animate(target: isSelected ? 1 : 0)
             .scale(duration: 200.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeOutBack),
          );
        },
      ),
    );
  }
}

class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}
