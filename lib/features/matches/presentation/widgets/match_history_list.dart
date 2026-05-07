import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';

class MatchHistoryList extends StatelessWidget {
  final List<MatchEntity> matches;
  final int? perspectiveUserId;
  final int? perspectiveTeamId;
  final bool showStats;

  const MatchHistoryList({
    super.key,
    required this.matches,
    this.perspectiveUserId,
    this.perspectiveTeamId,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (matches.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    // Calcular estadísticas
    int wins = 0;
    int draws = 0;
    int losses = 0;

    for (var match in matches) {
      final result = _getMatchResult(match);
      if (result == 'Victoria') {
        wins++;
      } else if (result == 'Derrota') {
        losses++;
      } else {
        draws++;
      }
    }

    return Column(
      children: [
        if (showStats) ...[
          _buildStatsSummary(wins, draws, losses),
          const SizedBox(height: 24),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildHistoryCard(context, matches[index], isDark);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay partidos finalizados aún.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(int wins, int draws, int losses) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Victorias', wins.toString(), AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Empates', draws.toString(), Colors.yellow[600]!)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Derrotas', losses.toString(), Colors.red[400]!)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textMuted = isDark ? Colors.grey[400] : Colors.black54;

    final result = _getMatchResult(match);
    final resultColor = _getResultColor(result);
    final score = _getScoreDisplay(match);

    return InkWell(
      onTap: () => context.push('/match-history-detail/${match.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: textMuted),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMMM', 'es_VE').format(match.fechaInicioEstimada),
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: resultColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(color: resultColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: theme.dividerColor)
                  ),
                  child: ClipOval(
                    child: _getOpponentLogo(match) != null
                      ? Image.network(
                          _getOpponentLogo(match)!, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                        )
                      : const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs ${_getOpponentName(match)}',
                        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            match.nombreCancha ?? 'Ubicación',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  score,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMatchResult(MatchEntity match) {
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    if (golesA == golesB) return 'Empate';

    bool isMainTeam;
    if (perspectiveTeamId != null) {
      isMainTeam = match.idEquipoA == perspectiveTeamId;
    } else {
      isMainTeam = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    
    if (isMainTeam) {
      return golesA > golesB ? 'Victoria' : 'Derrota';
    } else {
      return golesB > golesA ? 'Victoria' : 'Derrota';
    }
  }

  Color _getResultColor(String result) {
    if (result == 'Victoria') return AppColors.primary;
    if (result == 'Derrota') return Colors.red[400]!;
    return Colors.yellow[600]!;
  }

  String _getScoreDisplay(MatchEntity match) {
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;
    return '$golesA - $golesB';
  }

  String _getOpponentName(MatchEntity match) {
    bool isMainTeam;
    if (perspectiveTeamId != null) {
      isMainTeam = match.idEquipoA == perspectiveTeamId;
    } else {
      isMainTeam = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    return isMainTeam ? (match.nombreEquipoB ?? 'Rival') : (match.nombreEquipoA ?? 'Rival');
  }

  String? _getOpponentLogo(MatchEntity match) {
    bool isMainTeam;
    if (perspectiveTeamId != null) {
      isMainTeam = match.idEquipoA == perspectiveTeamId;
    } else {
      isMainTeam = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    return isMainTeam ? match.logoEquipoB : match.logoEquipoA;
  }
}
