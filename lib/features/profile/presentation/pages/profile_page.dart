import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/matchday_marquee.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teams/presentation/bloc/my_teams_bloc.dart';
import '../../../teams/presentation/bloc/my_teams_event.dart';
import '../../../teams/presentation/bloc/my_teams_state.dart';
import '../../../teams/domain/entities/team_entity.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_skeleton.dart';

import '../../domain/entities/profile_entity.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileEntity? _cachedProfile;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.go('/welcome');
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is ProfileLoaded) {
          setState(() => _cachedProfile = state.profile);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading && _cachedProfile == null) {
              return const ProfileSkeleton();
            }

            final profile = _cachedProfile;
            if (profile == null) {
              return const Center(child: Text('Cargando perfil...'));
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ProfileBloc>().add(LoadProfileEvent());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, profile, isDark),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        children: [
                          _buildStatisticsGrid(profile, isDark),
                          const SizedBox(height: 32),
                          BlocProvider<MyTeamsBloc>(
                            create: (_) =>
                                sl<MyTeamsBloc>()..add(LoadMyTeamsEvent()),
                            child: BlocBuilder<MyTeamsBloc, MyTeamsState>(
                              builder: (context, myTeamsState) {
                                if (myTeamsState is MyTeamsLoaded) {
                                  return _buildMyTeamsSection(
                                    myTeamsState.teams,
                                    isDark,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildPremiumActionList(context, profile, isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    UserProfileEntity profile,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.push('/configuracion'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image/Gradient
            if (profile.photoUrl != null &&
                profile.photoUrl!.startsWith('http'))
              Image.network(profile.photoUrl!, fit: BoxFit.cover)
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 120, color: Colors.white24),
                ),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // User Info
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MatchDayMarquee(
                          text: profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.role.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileBadge(
                    'ID: #${profile.id.toString().padLeft(6, '0')}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(UserProfileEntity profile, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          'Jugados',
          profile.partidosJugados.toString(),
          Icons.sports_soccer_rounded,
          isDark,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Organizados',
          profile.partidosOrganizados.toString(),
          Icons.workspace_premium_rounded,
          isDark,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Rating',
          profile.rating.toStringAsFixed(1),
          Icons.star_rounded,
          isDark,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTeamsSection(List<TeamEntity> teams, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MIS EQUIPOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/my-teams'),
              child: const Text(
                'VER TODOS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (teams.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1F2937).withValues(alpha: 0.5)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'Aún no tienes equipos',
                style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return _buildPremiumTeamCard(team, isDark);
              },
            ),
          ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildPremiumTeamCard(TeamEntity team, bool isDark) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.orange],
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isDark ? Colors.black : Colors.white,
              backgroundImage: team.logo.startsWith('http')
                  ? NetworkImage(team.logo)
                  : null,
              child: !team.logo.startsWith('http')
                  ? Text(
                      team.logo.isNotEmpty ? team.logo : '🛡️',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          Text(
            team.sportName,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionList(
    BuildContext context,
    UserProfileEntity profile,
    bool isDark,
  ) {
    return Column(
          children: [
            _buildActionCard(
              'Editar Perfil',
              'Actualiza tu información personal',
              Icons.edit_note_rounded,
              AppColors.primary,
              isDark,
              () => context.push(
                '/editar-perfil',
                extra: {
                  'profile': profile,
                  'bloc': context.read<ProfileBloc>(),
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              'Gestión de Pagos',
              'Tus cuentas y comprobantes',
              Icons.account_balance_wallet_rounded,
              Colors.orangeAccent,
              isDark,
              () => context.push('/payment-management'),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              'Historial de Partidos',
              'Resultados y estadísticas pasadas',
              Icons.history_rounded,
              Colors.blueAccent,
              isDark,
              () => context.push('/match-history'),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              'Configuración',
              'Privacidad y ajustes de la cuenta',
              Icons.settings_suggest_rounded,
              Colors.blueGrey,
              isDark,
              () => context.push('/configuracion'),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return AnimatedBouncingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1F2937).withValues(alpha: 0.6)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
