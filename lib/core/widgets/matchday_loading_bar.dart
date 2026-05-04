import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MatchDayLoadingBar extends StatelessWidget {
  final bool isLoading;
  final double minHeight;
  final EdgeInsetsGeometry? padding;

  const MatchDayLoadingBar({
    super.key,
    required this.isLoading,
    this.minHeight = 2.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox(height: 10);
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8.0),
      child: const LinearProgressIndicator(
        color: AppColors.primary,
        minHeight: 1.5,
      ),
    );
  }
}
