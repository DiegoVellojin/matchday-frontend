import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Obtenemos los fondos directamente de la configuración de AppTheme (ThemeBloc)
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    
    // Y definimos los bordes/textos dependiendo del modo
    final borderColor = isDark ? AppColors.border : theme.dividerColor.withValues(alpha: 0.1);
    final textMainColor = isDark ? AppColors.textMain : Colors.black87;
    final listHeaderColor = isDark ? const Color(0xFF252525) : theme.colorScheme.surfaceContainerHighest;

    return Container(
      color: backgroundColor,
      child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardInitial) {
            context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is LeaderboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
          } else if (state is LeaderboardLoaded) {
            if (state.leaderboard.isEmpty) {
              return Center(
                child: Text(
                  'No hay equipos en la clasificación.',
                  style: TextStyle(color: isDark ? AppColors.textMuted : Colors.black54),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clasificación Global',
                      style: TextStyle(
                        color: textMainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Podio Top 3
                    if (state.leaderboard.isNotEmpty)
                      _buildPodium(state.leaderboard, isDark, surfaceColor),
                    
                    const SizedBox(height: 32),
                    
                    // Lista del resto (Clasificación General)
                    _buildList(state.leaderboard, isDark, surfaceColor, borderColor, textMainColor, listHeaderColor),
                    
                    const SizedBox(height: 24), // padding inferior
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryEntity> teams, bool isDark, Color surfaceColor) {
    final first = teams.isNotEmpty ? teams[0] : null;
    final second = teams.length > 1 ? teams[1] : null;
    final third = teams.length > 2 ? teams[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2do Lugar
        if (second != null)
          Expanded(child: _buildPodiumColumn(second, 2, const Color(0xFFC0C0C0), 110, isDark, surfaceColor)),
        if (second != null) const SizedBox(width: 8),
        
        // 1er Lugar
        if (first != null)
          Expanded(child: _buildPodiumColumn(first, 1, const Color(0xFFFFD700), 140, isDark, surfaceColor)),
        
        // 3er Lugar
        if (third != null) const SizedBox(width: 8),
        if (third != null)
          Expanded(child: _buildPodiumColumn(third, 3, const Color(0xFFCD7F32), 95, isDark, surfaceColor)),
      ],
    );
  }

  Widget _buildPodiumColumn(LeaderboardEntryEntity team, int position, Color color, double height, bool isDark, Color surfaceColor) {
    final double avatarSize = position == 1 ? 80 : 64;
    final double iconSize = position == 1 ? 40 : 32;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: team.urlLogoEquipo != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(team.urlLogoEquipo!),
                    radius: (avatarSize / 2) - 4, // Restamos el borde
                    backgroundColor: Colors.transparent,
                  )
                : Icon(Icons.shield, color: color, size: iconSize),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: color, size: position == 1 ? 32 : 24),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  team.nombreEquipo,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: position == 1 ? FontWeight.bold : FontWeight.w600,
                    fontSize: position == 1 ? 14 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${team.puntosTotales} pts',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<LeaderboardEntryEntity> teams, bool isDark, Color surfaceColor, Color borderColor, Color textMainColor, Color listHeaderColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: listHeaderColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Text(
              'Clasificación General',
              style: TextStyle(
                color: textMainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teams.length,
            separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
            itemBuilder: (context, index) {
              final team = teams[index];
              final isTop3 = team.posicion <= 3;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Posición
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isTop3 ? AppColors.primary : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: Text(
                          '${team.posicion}',
                          style: TextStyle(
                            color: isTop3 ? Colors.black : textMainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
                      ),
                      child: Center(
                        child: team.urlLogoEquipo != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(team.urlLogoEquipo!),
                                radius: 20,
                              )
                            : Icon(Icons.shield, color: isDark ? AppColors.textMuted : Colors.black54, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Nombre y Detalle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.nombreEquipo,
                            style: TextStyle(
                              color: textMainColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${team.deporte} • ${team.victorias} victorias',
                            style: TextStyle(
                              color: isDark ? AppColors.textMuted : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Puntos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${team.puntosTotales}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'pts',
                          style: TextStyle(
                            color: isDark ? AppColors.textMuted : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
