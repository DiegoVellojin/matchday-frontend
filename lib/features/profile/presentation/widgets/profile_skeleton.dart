import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Header Skeleton
          MatchDayShimmer.rounded(height: 160, borderRadius: 32),
          const SizedBox(height: 32),

          // Stats Grid Skeleton
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  child: MatchDayShimmer.rounded(height: 110, borderRadius: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Teams Section Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatchDayShimmer.rounded(height: 12, width: 150),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  2,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == 1 ? 0 : 6,
                      ),
                      child: MatchDayShimmer.rounded(
                        height: 140,
                        borderRadius: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Actions Skeleton
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: MatchDayShimmer.rounded(height: 60, borderRadius: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
