import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class TeamDashboardSkeleton extends StatelessWidget {
  const TeamDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: const MatchDayShimmer.rectangular(height: 300),
              title: MatchDayShimmer.rounded(height: 20, width: 120),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
        ],
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == 2 ? 0 : 6,
                      ),
                      child: MatchDayShimmer.rounded(
                        height: 100,
                        borderRadius: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              MatchDayShimmer.rounded(height: 56, borderRadius: 20),
              const SizedBox(height: 24),
              MatchDayShimmer.rounded(height: 14, width: 150),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MatchDayShimmer.rounded(height: 70, borderRadius: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
