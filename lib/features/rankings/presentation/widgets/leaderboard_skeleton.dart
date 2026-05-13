import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MatchDayShimmer.rounded(height: 22, width: 100),
              const MatchDayShimmer.circular(size: 28),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Sport Filters Skeleton
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: MatchDayShimmer.rounded(height: 36, width: 80),
            )),
          ),
        ),
        const SizedBox(height: 12),
        // Period Filters Skeleton
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MatchDayShimmer.rounded(height: 32, width: 100),
            )),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Podium Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildPodiumColumnSkeleton(110, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPodiumColumnSkeleton(140, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPodiumColumnSkeleton(95, isDark)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MatchDayShimmer.rounded(height: 12, width: 140),
              ),
              const SizedBox(height: 16),
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: Row(
                    children: [
                      MatchDayShimmer.rounded(height: 16, width: 20),
                      const SizedBox(width: 12),
                      const MatchDayShimmer.circular(size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MatchDayShimmer.rounded(height: 16, width: 120),
                            const SizedBox(height: 6),
                            MatchDayShimmer.rounded(height: 12, width: 80),
                          ],
                        ),
                      ),
                      MatchDayShimmer.rounded(height: 20, width: 40),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumColumnSkeleton(double height, bool isDark) {
    return Column(
      children: [
        MatchDayShimmer.circular(size: height == 140 ? 90 : 75),
        const SizedBox(height: 12),
        MatchDayShimmer.rounded(
          height: height + 40,
          width: double.infinity,
          borderRadius: 24,
        ),
      ],
    );
  }
}
