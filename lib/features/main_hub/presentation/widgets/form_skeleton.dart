import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class FormSkeleton extends StatelessWidget {
  final bool hasImagePicker;
  const FormSkeleton({super.key, this.hasImagePicker = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImagePicker) ...[
            const Center(child: MatchDayShimmer.circular(size: 140)),
            const SizedBox(height: 32),
          ],
          for (int i = 0; i < 4; i++) ...[
            MatchDayShimmer.rounded(height: 12, width: 120),
            const SizedBox(height: 12),
            MatchDayShimmer.rounded(height: 56, borderRadius: 16),
            const SizedBox(height: 24),
          ],
          MatchDayShimmer.rounded(height: 100, borderRadius: 24),
          const SizedBox(height: 48),
          MatchDayShimmer.rounded(height: 56, borderRadius: 16),
        ],
      ),
    );
  }
}
