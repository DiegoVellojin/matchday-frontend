import 'package:flutter/material.dart';
import '../../../../core/widgets/matchday_shimmer.dart';

class FormSkeleton extends StatelessWidget {
  final bool hasImagePicker;
  const FormSkeleton({super.key, this.hasImagePicker = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImagePicker) ...[
            Center(child: MatchDayShimmer.rounded(height: 120, width: 120, borderRadius: 60)),
            const SizedBox(height: 24),
          ],
          for (int i = 0; i < 4; i++) ...[
            MatchDayShimmer.rounded(height: 14, width: 150),
            const SizedBox(height: 8),
            MatchDayShimmer.rounded(height: 56, borderRadius: 12),
            const SizedBox(height: 24),
          ],
          MatchDayShimmer.rounded(height: 80, borderRadius: 16),
          const SizedBox(height: 40),
          MatchDayShimmer.rounded(height: 56, borderRadius: 12),
        ],
      ),
    );
  }
}
