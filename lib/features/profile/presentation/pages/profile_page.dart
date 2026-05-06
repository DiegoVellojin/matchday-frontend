import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teams/presentation/bloc/my_teams_bloc.dart';
import '../../../teams/presentation/bloc/my_teams_event.dart';
import '../../../teams/presentation/bloc/my_teams_state.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../../../teams/presentation/pages/my_teams_page.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';

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
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return MatchDayLoadingBar(isLoading: state is ProfileLoading);
              },
            ),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading && _cachedProfile == null) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (_cachedProfile != null) {
                    final profile = _cachedProfile!;
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(LoadProfileEvent());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileHeader(profile)
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                            const SizedBox(height: 24),
                            _buildStatistics(profile.rating)
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 200.ms)
                                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                            const SizedBox(height: 24),
                            BlocProvider<MyTeamsBloc>(
                              create: (_) => sl<MyTeamsBloc>()..add(LoadMyTeamsEvent()),
                              child: BlocBuilder<MyTeamsBloc, MyTeamsState>(
                                builder: (context, myTeamsState) {
                                  if (myTeamsState is MyTeamsLoaded) {
                                    return _buildMyTeamsSection(myTeamsState.teams);
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, profile)
                                .animate()
                                .fadeIn(duration: 600.ms, delay: 600.ms)
                                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                          ],
                        ),
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'No se pudo cargar el perfil.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Perfil',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark ? AppColors.border : Colors.grey.shade300,
          height: 1,
        ),
      ),
    );
  }


  Widget _buildProfileHeader(dynamic profile) {
    final photoUrl = profile.photoUrl as String?;

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),

            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: photoUrl != null && photoUrl.startsWith('http')
                ? Image.network(
                    photoUrl, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.person, size: 48, color: Colors.grey)),
                  )
                : const Center(
                    child: Text('👤', style: TextStyle(fontSize: 48)),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),

          ),
          child: Text(
            profile.role,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(double rating) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildStatCard(Icons.emoji_events, '0', 'Partidos\nJugados'),
        _buildStatCard(Icons.workspace_premium, '0', 'Organizados'),
        _buildStatCard(Icons.star, rating.toStringAsFixed(1), 'Calificación'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : Colors.grey.shade300,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamsSection(List<TeamEntity> teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Equipos',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyTeamsPage()),
                );
              },

              icon: const Icon(
                Icons.groups,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'Ver Todos',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (teams.isEmpty)
          const Text(
            'No perteneces a ningún equipo todavía.',
            style: TextStyle(color: AppColors.textMuted),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return _buildTeamCard(team);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTeamCard(TeamEntity team) {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : Colors.grey.shade300,
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: team.logo.startsWith('http')
                  ? Image.network(
                      team.logo, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                    )
                  : Center(
                      child: Text(
                        team.logo.isNotEmpty ? team.logo : '⚽',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            team.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserProfileEntity profile) {
    return Column(
      children: [
        _buildMenuButton(
          label: 'Editar Perfil',
          onPressed: () => context.push(
            '/editar-perfil',
            extra: {'profile': profile, 'bloc': context.read<ProfileBloc>()},
          ),
        ),
        const SizedBox(height: 12),

        _buildMenuButton(
          label: 'Historial de Partidos',
          onPressed: () => context.push('/match-history'),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          label: 'Configuración',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuración próximamente')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
        child: AnimatedBouncingButton(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.border : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),

        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(LogoutEvent());
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
