import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MatchesSkeleton extends StatelessWidget {
  const MatchesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const MatchDayShimmer.circular(size: 50),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MatchDayShimmer.rounded(height: 20, width: 140),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            MatchDayShimmer.rounded(height: 16, width: 60),
                            const SizedBox(width: 8),
                            MatchDayShimmer.rounded(height: 14, width: 80),
                          ],
                        ),
                      ],
                    ),
                  ),
                  MatchDayShimmer.rounded(height: 24, width: 70),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  MatchDayShimmer.rounded(height: 14, width: 80),
                  const SizedBox(width: 16),
                  MatchDayShimmer.rounded(height: 14, width: 60),
                  const Spacer(),
                  MatchDayShimmer.rounded(height: 36, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
