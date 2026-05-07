import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamDashboardSkeleton extends StatelessWidget {
  const TeamDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: MatchDayShimmer.rectangular(height: 250),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Stats Row Skeleton
                  Row(
                    children: List.generate(3, (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: MatchDayShimmer.rounded(height: 80, borderRadius: 12),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tabs Skeleton
                  MatchDayShimmer.rounded(height: 50, borderRadius: 12),
                  const SizedBox(height: 24),
                  
                  // Content Skeleton
                  ...List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MatchDayShimmer.rounded(height: 70, borderRadius: 16),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
