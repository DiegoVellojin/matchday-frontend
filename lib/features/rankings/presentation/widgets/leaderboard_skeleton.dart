import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MatchDayShimmer.rounded(height: 24, width: 200),
          const SizedBox(height: 24),
          
          // Podium Skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const MatchDayShimmer.circular(size: 70),
                    const SizedBox(height: 12),
                    MatchDayShimmer.rounded(height: 140, borderRadius: 24),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    const MatchDayShimmer.circular(size: 85),
                    const SizedBox(height: 12),
                    MatchDayShimmer.rounded(height: 170, borderRadius: 24),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    const MatchDayShimmer.circular(size: 70),
                    const SizedBox(height: 12),
                    MatchDayShimmer.rounded(height: 125, borderRadius: 24),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // List Skeleton
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(5, (index) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const MatchDayShimmer.circular(size: 32),
                    const SizedBox(width: 16),
                    const MatchDayShimmer.circular(size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatchDayShimmer.rounded(height: 16, width: 120),
                          const SizedBox(height: 8),
                          MatchDayShimmer.rounded(height: 12, width: 80),
                        ],
                      ),
                    ),
                    MatchDayShimmer.rounded(height: 24, width: 40),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
