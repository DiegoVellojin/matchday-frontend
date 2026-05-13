import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MatchDayMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double velocity;
  final double blankSpace;
  final Duration pauseAfterRound;
  final TextAlign textAlign;

  const MatchDayMarquee({
    super.key,
    required this.text,
    required this.style,
    this.velocity = 35.0,
    this.blankSpace = 40.0,
    this.pauseAfterRound = const Duration(seconds: 3),
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        // Si cabe perfectamente, mostramos el texto normal
        if (textPainter.width <= constraints.maxWidth) {
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.visible,
          );
        }

        // Si no cabe, activamos el efecto banner
        return SizedBox(
          // Añadimos un pequeño buffer a la altura para evitar recortes visuales por la fuente
          height: textPainter.height + 4,
          child: Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: blankSpace,
            velocity: velocity,
            pauseAfterRound: pauseAfterRound,
            startAfter: const Duration(
              seconds: 1,
            ), // Esperamos un segundo antes de empezar a mover
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        );
      },
    );
  }
}
