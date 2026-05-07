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
import '../widgets/profile_skeleton.dart';
import 'dart:ui';

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
                    return const ProfileSkeleton();
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
                            _buildStatistics(profile)
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.sports_soccer,
                size: 120,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Foto con borde premium
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: colorScheme.surface,
                      backgroundImage: photoUrl != null && photoUrl.startsWith('http')
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || !photoUrl.startsWith('http')
                          ? const Icon(Icons.person, size: 45, color: AppColors.textMuted)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Información del Jugador
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _MarqueeText(
                                text: profile.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppColors.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${profile.id.toString().padLeft(6, '0')}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profile.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(UserProfileEntity profile) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildStatCard(Icons.emoji_events, profile.partidosJugados.toString(), 'Partidos\nJugados'),
        _buildStatCard(Icons.workspace_premium, profile.partidosOrganizados.toString(), 'Organizados'),
        _buildStatCard(Icons.star, profile.rating.toStringAsFixed(1), 'Calificación'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark 
              ? colorScheme.surface.withValues(alpha: 0.6)
              : colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
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
          label: 'Gestión de Pagos',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Colors.orange,
          showBadge: true,
          onPressed: () => context.push('/payment-management'),
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
    IconData? icon,
    Color? iconColor,
    bool showBadge = false,
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
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (showBadge)
                Positioned(
                  top: -4,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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

/// Widget personalizado para nombres largos con efecto Marquee (deslizamiento).
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Iniciar la animación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    // Pequeño delay inicial
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_scrollController.hasClients) return;

    // Solo animamos si el texto es más largo que el contenedor
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;

      // Deslizar hasta el final
      await _scrollController.animateTo(
        maxScroll,
        duration: Duration(milliseconds: (maxScroll * 40).toInt()),
        curve: Curves.linear,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;

      // Regresar al inicio suavemente
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}
