import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MatchHistorySkeleton extends StatelessWidget {
  const MatchHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Stats Summary Skeleton
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 6,
                  right: index == 2 ? 0 : 6,
                ),
                child: MatchDayShimmer.rounded(height: 100, borderRadius: 20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // History Cards Skeleton
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, _) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MatchDayShimmer.rounded(height: 14, width: 120),
                    MatchDayShimmer.rounded(
                      height: 24,
                      width: 80,
                      borderRadius: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const MatchDayShimmer.circular(size: 50),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatchDayShimmer.rounded(height: 18, width: 140),
                          const SizedBox(height: 8),
                          MatchDayShimmer.rounded(height: 14, width: 180),
                        ],
                      ),
                    ),
                    MatchDayShimmer.rounded(
                      height: 44,
                      width: 70,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
