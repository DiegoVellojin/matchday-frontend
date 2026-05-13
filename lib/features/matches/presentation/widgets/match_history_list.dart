import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          _buildStatsSummary(wins, draws, losses)
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.2, end: 0),
          const SizedBox(height: 24),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildHistoryCard(context, matches[index], isDark)
              .animate()
              .fadeIn(delay: (index * 100).ms, duration: 600.ms)
              .slideX(begin: 0.1, end: 0);
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
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: AppColors.primary.withValues(alpha: 0.2)),
          
          const SizedBox(height: 24),
          Text(
            'Historial limpio',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Este equipo aún no ha completado ningún partido. ¡Es hora de saltar al campo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildStatsSummary(int wins, int draws, int losses) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Victorias', wins.toString(), AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Empates', draws.toString(), Colors.orangeAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Derrotas', losses.toString(), Colors.redAccent)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textMuted = isDark ? Colors.grey[400] : Colors.black54;

    final result = _getMatchResult(match);
    final resultColor = _getResultColor(result);
    final score = _getScoreDisplay(match);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
      child: InkWell(
        onTap: () => context.push('/match-history-detail/${match.id}'),
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: textMuted),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat("EEE, d 'de' MMMM", 'es_VE').format(match.fechaInicioEstimada.toLocal()).toUpperCase(),
                        style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: resultColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: resultColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      result.toUpperCase(),
                      style: TextStyle(color: resultColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey[100], 
                      shape: BoxShape.circle, 
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), width: 1.5),
                    ),
                    child: ClipOval(
                      child: _getOpponentLogo(match) != null
                        ? Image.network(
                            _getOpponentLogo(match)!, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_soccer_rounded, size: 24, color: AppColors.primary),
                          )
                        : const Icon(Icons.sports_soccer_rounded, size: 24, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VS',
                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getOpponentName(match).toUpperCase(),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 12, color: cs.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                match.nombreCancha?.toUpperCase() ?? 'SEDE NO REGISTRADA',
                                style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      score,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, 
                        fontSize: 22, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
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

  String _getMatchResult(MatchEntity match) {
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    if (golesA == golesB) return 'Empate';

    bool isTeamA;
    if (match.idEquipoUsuario != null) {
      isTeamA = match.idEquipoUsuario == match.idEquipoA;
    } else if (perspectiveTeamId != null) {
      isTeamA = match.idEquipoA == perspectiveTeamId;
    } else {
      isTeamA = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    
    if (isTeamA) {
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

    bool isTeamA;
    if (match.idEquipoUsuario != null) {
      isTeamA = match.idEquipoUsuario == match.idEquipoA;
    } else if (perspectiveTeamId != null) {
      isTeamA = match.idEquipoA == perspectiveTeamId;
    } else {
      isTeamA = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }

    return isTeamA ? '$golesA - $golesB' : '$golesB - $golesA';
  }

  String _getOpponentName(MatchEntity match) {
    bool isTeamA;
    if (match.idEquipoUsuario != null) {
      isTeamA = match.idEquipoUsuario == match.idEquipoA;
    } else if (perspectiveTeamId != null) {
      isTeamA = match.idEquipoA == perspectiveTeamId;
    } else {
      isTeamA = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    return isTeamA ? (match.nombreEquipoB ?? 'Rival') : (match.nombreEquipoA ?? 'Rival');
  }

  String? _getOpponentLogo(MatchEntity match) {
    bool isTeamA;
    if (match.idEquipoUsuario != null) {
      isTeamA = match.idEquipoUsuario == match.idEquipoA;
    } else if (perspectiveTeamId != null) {
      isTeamA = match.idEquipoA == perspectiveTeamId;
    } else {
      isTeamA = perspectiveUserId != null && match.idUsuarioOrg == perspectiveUserId;
    }
    return isTeamA ? match.logoEquipoB : match.logoEquipoA;
  }
}
