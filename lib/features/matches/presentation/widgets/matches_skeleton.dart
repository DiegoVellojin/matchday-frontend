import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MatchesSkeleton extends StatelessWidget {
  const MatchesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MatchDayShimmer.circular(size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MatchDayShimmer.rounded(height: 20, width: 180),
                  const SizedBox(height: 8),
                  MatchDayShimmer.rounded(height: 14, width: 100),
                  const SizedBox(height: 16),
                  MatchDayShimmer.rounded(height: 14, width: 200),
                  const SizedBox(height: 8),
                  MatchDayShimmer.rounded(height: 14, width: 150),
                  const SizedBox(height: 16),
                  MatchDayShimmer.rounded(height: 40, borderRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
