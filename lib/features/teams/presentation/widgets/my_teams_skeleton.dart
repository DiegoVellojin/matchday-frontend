import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class MyTeamsSkeleton extends StatelessWidget {
  const MyTeamsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const MatchDayShimmer.circular(size: 68),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MatchDayShimmer.rounded(height: 20, width: 140),
                        const SizedBox(height: 10),
                        MatchDayShimmer.rounded(height: 14, width: 80),
                        const SizedBox(height: 10),
                        MatchDayShimmer.rounded(height: 18, width: 90),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MatchDayShimmer.rounded(
                      height: 44,
                      borderRadius: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MatchDayShimmer.rounded(
                      height: 44,
                      borderRadius: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
