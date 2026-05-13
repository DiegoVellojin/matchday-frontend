import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_entity.dart';

class TeamDiscoveryCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback onRequestJoin;

  const TeamDiscoveryCard({
    super.key,
    required this.team,
    required this.onRequestJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/team-dashboard/${team.id}'),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Subtle watermark icon
                Positioned(
                  right: -10,
                  top: -10,
                  child: Icon(
                    team.sportName.contains('Fútbol') ? Icons.sports_soccer : Icons.sports,
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.03),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.5)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: isDark ? Colors.black : Colors.white,
                              backgroundImage: (team.logo.startsWith('http'))
                                  ? NetworkImage(team.logo)
                                  : null,
                              child: (!team.logo.startsWith('http'))
                                  ? Text(
                                      team.logo.isNotEmpty ? team.logo : '🛡️',
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  : null,
                            ),
                          ),
                          _buildRecruitingBadge(team.isRecruiting),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.emoji_events_outlined, size: 12, color: AppColors.primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              team.sportName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMemberInfo(team, isDark),
                      const Spacer(),
                      _buildActionButton(context, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecruitingBadge(bool isRecruiting) {
    if (!isRecruiting) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add_rounded, size: 10, color: Colors.greenAccent),
          SizedBox(width: 4),
          Text(
            'BUSCA',
            style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfo(TeamEntity team, bool isDark) {
    final percent = team.currentMembers / team.maxMembers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${team.currentMembers}/${team.maxMembers} Jugadores',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.7)),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDark) {
    if (team.soyMiembro) {
      return Container(
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'MI EQUIPO',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRequestJoin,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'UNIRSE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
