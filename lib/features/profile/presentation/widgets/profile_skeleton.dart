import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Skeleton
          MatchDayShimmer.rounded(
            height: 140,
            borderRadius: 24,
          ),
          const SizedBox(height: 24),
          
          // Stats Grid Skeleton
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: List.generate(3, (index) => MatchDayShimmer.rounded(
              height: 100,
              borderRadius: 16,
            )),
          ),
          const SizedBox(height: 24),
          
          // Teams Section Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatchDayShimmer.rounded(height: 24, width: 150),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: MatchDayShimmer.rounded(height: 120, borderRadius: 12),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Actions Skeleton
          Column(
            children: List.generate(2, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: MatchDayShimmer.rounded(height: 55, borderRadius: 12),
            )),
          ),
        ],
      ),
    );
  }
}
