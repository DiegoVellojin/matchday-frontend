import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamSettingsSkeleton extends StatelessWidget {
  const TeamSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          MatchDayShimmer.rounded(height: 16, width: 120),
          const SizedBox(height: 16),
          
          // Image Picker / Header Skeleton
          Center(
            child: const MatchDayShimmer.circular(size: 100),
          ),
          const SizedBox(height: 24),
          
          // Fields
          ...List.generate(3, (index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatchDayShimmer.rounded(height: 14, width: 100),
              const SizedBox(height: 8),
              MatchDayShimmer.rounded(height: 55, borderRadius: 12),
              const SizedBox(height: 16),
            ],
          )),
          
          // Members Section
          MatchDayShimmer.rounded(height: 16, width: 150),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(3, (index) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const MatchDayShimmer.circular(size: 40),
                    const SizedBox(width: 12),
                    Expanded(child: MatchDayShimmer.rounded(height: 20)),
                    const SizedBox(width: 12),
                    MatchDayShimmer.rounded(height: 24, width: 60),
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
