import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class EditProfileSkeleton extends StatelessWidget {
  const EditProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const MatchDayShimmer.circular(size: 100),
                const SizedBox(height: 12),
                MatchDayShimmer.rounded(height: 14, width: 80),
              ],
            ),
          ),
          const SizedBox(height: 30),
          MatchDayShimmer.rounded(height: 14, width: 120),
          const SizedBox(height: 8),
          MatchDayShimmer.rounded(height: 56, borderRadius: 12),
          const SizedBox(height: 20),
          MatchDayShimmer.rounded(height: 14, width: 80),
          const SizedBox(height: 8),
          MatchDayShimmer.rounded(height: 56, borderRadius: 12),
          const SizedBox(height: 20),
          MatchDayShimmer.rounded(height: 56, borderRadius: 12),
          const SizedBox(height: 40),
          MatchDayShimmer.rounded(height: 56, borderRadius: 12),
        ],
      ),
    );
  }
}
