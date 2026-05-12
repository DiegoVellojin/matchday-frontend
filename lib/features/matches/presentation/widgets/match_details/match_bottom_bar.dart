import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'match_details_action_handler.dart';

class MatchBottomBar extends StatelessWidget {
  final MatchDetailActions actions;

  const MatchBottomBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<Widget> buttons = [];

    // Secondary Actions (Outlined)
    for (var action in actions.secondaryActions) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: action.onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: theme.dividerColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action.label),
          ),
        ),
      );
    }

    // Primary Actions (Elevated - AppColors.primary)
    for (var action in actions.primaryActions) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: action.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // Destructive Actions (Elevated - AppColors.error)
    for (var action in actions.destructiveActions) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: action.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // Añadir espaciado entre los botones
    List<Widget> spacedButtons = [];
    for (int i = 0; i < buttons.length; i++) {
      spacedButtons.add(buttons[i]);
      if (i < buttons.length - 1) {
        spacedButtons.add(const SizedBox(width: 12));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: spacedButtons,
      ),
    );
  }
}
