import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class MatchHistoryPage extends StatelessWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchesEvent(status: 'completada', mine: true)),
      child: const _MatchHistoryView(),
    );
  }
}

class _MatchHistoryView extends StatelessWidget {
  const _MatchHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Historial de Partidos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is MatchesError) {
            return Center(child: Text(state.message));
          } else if (state is MatchesLoaded) {
            final matches = state.matches;
            if (matches.isEmpty) {
              return _buildEmptyState(context, isDark);
            }
            return _buildContent(context, matches, currentUserId, isDark);
          }
          return const SizedBox.shrink();
        },
      ),
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
            'No tienes partidos finalizados aún.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<MatchEntity> matches, int? currentUserId, bool isDark) {
    // Calcular estadísticas
    int wins = 0;
    int draws = 0;
    int losses = 0;

    for (var match in matches) {
      final result = _getMatchResult(match, currentUserId);
      if (result == 'Victoria') {
        wins++;
      } else if (result == 'Derrota') {
        losses++;
      } else {
        draws++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsSummary(wins, draws, losses),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildHistoryCard(context, matches[index], currentUserId, isDark);
            },
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

  Widget _buildHistoryCard(BuildContext context, MatchEntity match, int? currentUserId, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textMuted = isDark ? Colors.grey[400] : Colors.black54;

    final result = _getMatchResult(match, currentUserId);
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
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: theme.dividerColor)),
                  child: ClipOval(
                    child: (match.logoEquipoA != null || match.logoEquipoB != null) 
                      ? Image.network(
                          _getOpponentLogo(match, currentUserId) ?? '', 
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
                        'vs ${_getOpponentName(match, currentUserId)}',
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

  String _getMatchResult(MatchEntity match, int? currentUserId) {
    // Si somos Capitán A, miramos goles A
    // Si somos Capitán B, miramos goles B
    // Para simplificar, asumimos que idUsuarioOrg es el equipo A.
    // En el seed, ID 1 es Capitan A del partido 1.
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    final isTeamA = currentUserId != null && match.idUsuarioOrg == currentUserId;
    
    if (golesA == golesB) return 'Empate';
    
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
    return '$golesA - $golesB';
  }

  String _getOpponentName(MatchEntity match, int? currentUserId) {
    final isTeamA = currentUserId != null && match.idUsuarioOrg == currentUserId;
    return isTeamA ? (match.nombreEquipoB ?? 'Rival') : (match.nombreEquipoA ?? 'Rival');
  }

  String? _getOpponentLogo(MatchEntity match, int? currentUserId) {
    final isTeamA = currentUserId != null && match.idUsuarioOrg == currentUserId;
    return isTeamA ? match.logoEquipoB : match.logoEquipoA;
  }
}
