import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MatchHistorySkeleton extends StatelessWidget {
  const MatchHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MatchDayShimmer.circular(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MatchDayShimmer.rounded(height: 16, width: 150),
                      const SizedBox(height: 4),
                      MatchDayShimmer.rounded(height: 12, width: 100),
                    ],
                  ),
                ),
                MatchDayShimmer.rounded(height: 24, width: 60, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            MatchDayShimmer.rounded(height: 14, width: double.infinity),
            const SizedBox(height: 8),
            MatchDayShimmer.rounded(height: 14, width: 200),
          ],
        ),
      ),
    );
  }
}
