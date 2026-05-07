import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../widgets/leaderboard_skeleton.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            return const LeaderboardSkeleton();
          } else if (state is LeaderboardLoading) {
            return const LeaderboardSkeleton();
          } else if (state is LeaderboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
          } else if (state is LeaderboardLoaded) {
            if (state.leaderboard.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.military_tech_outlined,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 2000.ms, color: AppColors.primary.withValues(alpha: 0.2)),
                    const SizedBox(height: 24),
                    Text(
                      'Sin rivales a la vista',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Aún no hay equipos compitiendo en esta liga. ¡Sé el primero en llegar a la cima!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms);
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
                      _buildPodium(state.leaderboard, isDark, surfaceColor)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Lista del resto (Clasificación General)
                    _buildList(state.leaderboard, isDark, surfaceColor, borderColor, textMainColor, listHeaderColor)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    
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
    final double avatarSize = position == 1 ? 90 : 75; // Un poco más grandes
    final double iconSize = position == 1 ? 48 : 38; // Mucho más grandes para el escudo

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar con resplandor
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: CircleAvatar(
                  backgroundColor: surfaceColor,
                  backgroundImage: team.urlLogoEquipo != null ? NetworkImage(team.urlLogoEquipo!) : null,
                  child: team.urlLogoEquipo == null ? Icon(Icons.shield, color: color, size: iconSize) : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: surfaceColor, width: 2),
                  ),
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Pedestal
        Container(
          width: double.infinity,
          height: height + 40, // Aumentamos un poco más para seguridad
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              // Icono de medalla/trofeo
              Icon(
                position == 1 ? Icons.emoji_events : Icons.military_tech,
                color: color,
                size: position == 1 ? 42 : 34,
              ),
              const SizedBox(height: 12),
              // Nombre del Equipo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  team.nombreEquipo,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: position == 1 ? 14 : 12,
                    height: 1.1,
                    shadows: isDark ? [
                      const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))
                    ] : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Puntos en un badge estilizado
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  '${team.puntosTotales} pts',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
              ).animate()
               .fadeIn(duration: 400.ms, delay: (index * 30).ms)
               .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
            },
          ),
        ],
      ),
    );
  }
}
