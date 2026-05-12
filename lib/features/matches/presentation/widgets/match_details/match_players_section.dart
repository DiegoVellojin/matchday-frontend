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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Alineaciones Confirmadas',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTeamLineup(
          match.nombreEquipoA ?? 'Equipo A',
          players.where((p) => p.idEquipo == match.idEquipoA).toList(),
          isDark,
          context,
        ),
        const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                teamName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${teamPlayers.length} Jugadores',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (teamPlayers.isEmpty)
            const Center(
              child: Text(
                'Sin jugadores registrados',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: teamPlayers.map((p) => _buildPlayerChip(p, isDark)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(MatchPlayer p, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: (p.urlFotoPerfil != null && p.urlFotoPerfil!.startsWith('http'))
                ? NetworkImage(p.urlFotoPerfil!)
                : null,
            child: (p.urlFotoPerfil == null || !p.urlFotoPerfil!.startsWith('http'))
                ? const Icon(Icons.person, size: 10, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            p.nombreUsuario,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
