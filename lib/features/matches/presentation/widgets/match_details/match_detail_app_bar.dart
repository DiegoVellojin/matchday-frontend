import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import 'match_details_action_handler.dart';
import '../../../domain/entities/match_entity.dart';

class MatchDetailAppBar extends StatelessWidget {
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

    if (name.contains('futbol') || name.contains('fútbol') || name.contains('soccer')) {
      return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000';
    }
    if (name.contains('basket') || name.contains('baloncesto')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=1000';
    }
    if (name.contains('volley') || name.contains('voleibol')) {
      return 'https://images.unsplash.com/photo-1666901356149-93f2eb3ba5a2?q=80&w=1000';
    }
    if (name.contains('tennis') || name.contains('tenis')) {
      return 'https://images.unsplash.com/flagged/photo-1576972405668-2d020a01cbfa?q=80&w=1000';
    }
    if (name.contains('padel') || name.contains('pádel') || name.contains('pickleball')) {
      return 'https://images.unsplash.com/photo-1657704358775-ed705c7388d2?q=80&w=1000';
    }
    if (name.contains('beisbol') || name.contains('béisbol') || name.contains('softbol') || name.contains('baseball')) {
      return 'https://images.unsplash.com/photo-1578432014316-48b448d79d57?q=80&w=1000';
    }
    if (name.contains('rugby')) {
      return 'https://images.unsplash.com/photo-1529663297269-6d349ec39b57?q=80&w=1000';
    }
    if (name.contains('ping') || name.contains('mesa')) {
      return 'https://images.unsplash.com/photo-1534158914592-062992fbe900?q=80&w=1000';
    }
    if (name.contains('futsal') || name.contains('sala')) {
      return 'https://images.unsplash.com/photo-1587384474964-3a06ce1ce699?q=80&w=1000';
    }
    return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.sportName?.toUpperCase() ?? 'PARTIDO',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              match.nombreEquipoA != null
                  ? '${match.nombreEquipoA} vs ${match.nombreEquipoB ?? '(Esperando rival)'}'
                  : 'Detalles del Encuentro',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isOrganizer && (match.estatus == 'publicada' || match.estatus == 'negociando'))
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => MatchDetailsActionHandler.handleCancelMatch(context, match.id),
          ),
      ],
    );
  }
}
