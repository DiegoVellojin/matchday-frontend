import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamDiscoverySkeleton extends StatelessWidget {
  const TeamDiscoverySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MatchDayShimmer.rounded(height: 40, width: 40, borderRadius: 8),
                MatchDayShimmer.rounded(height: 20, width: 60, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 12),
            MatchDayShimmer.rounded(height: 18, width: 100),
            const SizedBox(height: 8),
            MatchDayShimmer.rounded(height: 14, width: 80),
            const Spacer(),
            MatchDayShimmer.rounded(height: 36, borderRadius: 8),
          ],
        ),
      ),
    );
  }
}
