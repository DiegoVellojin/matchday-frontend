import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import 'match_details_action_handler.dart';
import '../../../domain/entities/match_entity.dart';
import '../../../../../core/widgets/matchday_marquee.dart';

class MatchDetailAppBar extends StatelessWidget {
  static const String _footballImage =
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000';
  static const String _basketballImage =
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=1000';
  static const String _padelImage =
      'https://images.unsplash.com/photo-1657704358775-ed705c7388d2?q=80&w=1000';
  static const String _tennisImage =
      'https://images.unsplash.com/photo-1627314387807-df615e8567de?q=80&w=1000';
  static const String _volleyballImage =
      'https://images.unsplash.com/photo-1666901356149-93f2eb3ba5a2?q=80&w=1000';
  static const String _baseballImage =
      'https://images.unsplash.com/photo-1471295253337-3ceaaedca402?q=80&w=1000';
  static const String _softballImage =
      'https://images.unsplash.com/photo-1622874279171-4333f26f404c?q=80&w=1000';
  static const String _futsalImage =
      'https://images.unsplash.com/photo-1587384474964-3a06ce1ce699?q=80&w=1000';
  static const String _pickleballImage =
      'https://images.unsplash.com/photo-1659318006095-4d44845f3a1b?q=80&w=1000';
  static const String _rugbyImage =
      'https://images.unsplash.com/photo-1529663297269-6d349ec39b57?q=80&w=1000';
  static const String _pingPongImage =
      'https://images.unsplash.com/photo-1646978567314-32cfd5a8854e?q=80&w=1000';

  final MatchEntity match;
  final bool isDark;
  final bool isOrganizer;

  const MatchDetailAppBar({
    super.key,
    required this.match,
    required this.isDark,
    required this.isOrganizer,
  });

  String _getSportImage(String? sportName) {
    final name = sportName?.toLowerCase() ?? '';

    if (name.contains('futbol') ||
        name.contains('fútbol') ||
        name.contains('soccer')) {
      return _footballImage;
    }
    if (name.contains('basket') || name.contains('baloncesto')) {
      return _basketballImage;
    }
    if (name.contains('padel') || name.contains('pádel')) {
      return _padelImage;
    }
    if (name.contains('tenis') || name.contains('tennis')) {
      return _tennisImage;
    }
    if (name.contains('voleibol') || name.contains('volleyball')) {
      return _volleyballImage;
    }
    if (name.contains('béisbol') ||
        name.contains('beisbol') ||
        name.contains('baseball')) {
      return _baseballImage;
    }
    if (name.contains('softbol') || name.contains('softball')) {
      return _softballImage;
    }
    if (name.contains('futsal')) {
      return _futsalImage;
    }
    if (name.contains('pickle') || name.contains('pickleball')) {
      return _pickleballImage;
    }
    if (name.contains('rugby')) {
      return _rugbyImage;
    }
    if (name.contains('ping') ||
        name.contains('ping pong') ||
        name.contains('pingpong') ||
        name.contains('tenis de mesa')) {
      return _pingPongImage;
    }

    return _footballImage;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isOrganizer &&
            (match.estatus == 'publicada' || match.estatus == 'negociando'))
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            onPressed: () =>
                MatchDetailsActionHandler.handleCancelMatch(context, match.id),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                match.sportName?.toUpperCase() ?? 'MATCH',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
            const SizedBox(height: 8),
            MatchDayMarquee(
              text: match.nombreEquipoA != null
                  ? '${match.nombreEquipoA} vs ${match.nombreEquipoB ?? '(Esperando rival)'}'
                  : 'Detalles del Encuentro',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 15),
                  Shadow(color: Colors.black54, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(_getSportImage(match.sportName), fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                    isDark
                        ? const Color(0xFF0F172A)
                        : Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
