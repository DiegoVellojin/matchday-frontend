import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamDiscoverySkeleton extends StatelessWidget {
  const TeamDiscoverySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(16.0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MatchDayShimmer.circular(size: 44),
                MatchDayShimmer.rounded(height: 20, width: 50, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),
            MatchDayShimmer.rounded(height: 16, width: 100),
            const SizedBox(height: 6),
            MatchDayShimmer.rounded(height: 12, width: 60),
            const SizedBox(height: 16),
            MatchDayShimmer.rounded(height: 10, width: 80),
            const SizedBox(height: 6),
            MatchDayShimmer.rounded(height: 4, borderRadius: 4),
            const Spacer(),
            MatchDayShimmer.rounded(height: 38, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
