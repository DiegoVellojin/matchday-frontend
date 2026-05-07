import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MatchDayShimmer extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const MatchDayShimmer.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  const MatchDayShimmer.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        shapeBorder = const CircleBorder();

  MatchDayShimmer.rounded({
    super.key,
    this.width = double.infinity,
    required this.height,
    double borderRadius = 12,
  }) : shapeBorder = RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}
