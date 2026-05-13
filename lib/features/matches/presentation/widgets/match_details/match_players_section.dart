import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

class MatchPlayersSection extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final List<MatchPlayer> players;
  final bool isLoading;

  const MatchPlayersSection({
    super.key,
    required this.match,
    required this.isDark,
    required this.players,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (players.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeamLineup(
          match.nombreEquipoA ?? 'Equipo A',
          players.where((p) => p.idEquipo == match.idEquipoA).toList(),
          isDark,
          context,
        ),
        const SizedBox(height: 16),
        _buildTeamLineup(
          match.nombreEquipoB ?? 'Equipo B',
          players.where((p) => p.idEquipo == match.idEquipoB).toList(),
          isDark,
          context,
        ),
      ],
    );
  }

  Widget _buildTeamLineup(String teamName, List<MatchPlayer> teamPlayers, bool isDark, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  teamName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${teamPlayers.length} Jugadores',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (teamPlayers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.person_off_rounded, color: isDark ? Colors.white24 : Colors.black12, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Sin jugadores registrados',
                      style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: teamPlayers.map((p) => _buildPlayerChip(p, isDark)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(MatchPlayer p, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              backgroundImage: (p.urlFotoPerfil != null && p.urlFotoPerfil!.startsWith('http'))
                  ? NetworkImage(p.urlFotoPerfil!)
                  : null,
              child: (p.urlFotoPerfil == null || !p.urlFotoPerfil!.startsWith('http'))
                  ? const Icon(Icons.person, size: 10, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            p.nombreUsuario,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
