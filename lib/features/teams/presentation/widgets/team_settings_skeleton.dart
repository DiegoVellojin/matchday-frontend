import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamSettingsSkeleton extends StatelessWidget {
  const TeamSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MatchDayShimmer.rounded(height: 12, width: 150),
          const SizedBox(height: 16),
          const Center(child: MatchDayShimmer.circular(size: 120)),
          const SizedBox(height: 32),
          ...List.generate(
            3,
            (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MatchDayShimmer.rounded(height: 10, width: 100),
                const SizedBox(height: 12),
                MatchDayShimmer.rounded(height: 56, borderRadius: 16),
                const SizedBox(height: 24),
              ],
            ),
          ),
          MatchDayShimmer.rounded(height: 12, width: 180),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const MatchDayShimmer.circular(size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MatchDayShimmer.rounded(
                          height: 18,
                          borderRadius: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      MatchDayShimmer.rounded(
                        height: 24,
                        width: 60,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          MatchDayShimmer.rounded(height: 56, borderRadius: 20),
        ],
      ),
    );
  }
}
