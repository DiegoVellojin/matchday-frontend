import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MyTeamsSkeleton extends StatelessWidget {
  const MyTeamsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const MatchDayShimmer.circular(size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MatchDayShimmer.rounded(height: 20, width: 140),
                      const SizedBox(height: 8),
                      MatchDayShimmer.rounded(height: 14, width: 80),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MatchDayShimmer.rounded(height: 40, borderRadius: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MatchDayShimmer.rounded(height: 40, borderRadius: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
