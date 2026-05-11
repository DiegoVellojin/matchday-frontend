import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/usecases/get_team_by_id_usecase.dart';
import '../../application/usecases/get_team_members_usecase.dart';
import '../../application/usecases/get_pending_requests_usecase.dart';
import '../../application/usecases/request_join_team_usecase.dart';
import '../../application/usecases/respond_to_join_request_usecase.dart';
import '../../domain/entities/team_entity.dart';
import 'package:share_plus/share_plus.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../matches/presentation/bloc/matches_bloc.dart';
import '../../../matches/presentation/widgets/match_history_list.dart';
import '../widgets/team_dashboard_skeleton.dart';


class TeamDashboardPage extends StatefulWidget {
  final int teamId;

  const TeamDashboardPage({super.key, required this.teamId});

  @override
  State<TeamDashboardPage> createState() => _TeamDashboardPageState();
}

class _TeamDashboardPageState extends State<TeamDashboardPage> {
  String _activeTab = 'roster';
  late Future<TeamEntity> _teamFuture;
  late Future<List<Map<String, dynamic>>> _membersFuture;
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  void _loadTeam() {
    _teamFuture = sl<GetTeamByIdUseCase>().call(widget.teamId).then((result) {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (team) => team,
      );
    });

    _membersFuture = sl<GetTeamMembersUseCase>().call(widget.teamId).then((result) {
      return result.fold(
        (failure) => <Map<String, dynamic>>[],
        (members) => members,
      );
    });

    _requestsFuture = sl<GetPendingRequestsUseCase>().call(widget.teamId).then((result) {
      return result.fold(
        (failure) => <Map<String, dynamic>>[],
        (requests) => requests,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocProvider(
        create: (context) => sl<MatchesBloc>()..add(LoadMatchesEvent(teamId: widget.teamId, status: 'completada')),
        child: FutureBuilder<TeamEntity>(
          future: _teamFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const TeamDashboardSkeleton();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() => _loadTeam()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Equipo no encontrado.'));
            }

            final team = snapshot.data!;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(context, team, colorScheme),
                ];
              },
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  children: [
                    _buildStatsRow(team, colorScheme),
                    const SizedBox(height: 24),
                    _buildTabs(colorScheme),
                    const SizedBox(height: 20),
                    _activeTab == 'roster'
                        ? _buildRosterTab(team, colorScheme)
                        : _buildHistoryTab(colorScheme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder<TeamEntity>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.soyMiembro) return const SizedBox.shrink();
          final team = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final result = await sl<RequestJoinTeamUseCase>().call(team.id);
                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${failure.message}')),
                      );
                    },
                    (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solicitud enviada con éxito')),
                      );
                      setState(() {
                        _loadTeam();
                      });
                    },
                  );
                },
                child: const Text(
                  'Solicitar Unirse al Equipo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeamEntity team, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.canPop() ? context.pop() : context.go('/hub'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.primary),
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text: '¡Únete a mi equipo ${team.name} en MatchDay! ⚽🏆 Ingresa aquí: https://matchday-backend-3qot.onrender.com/api/v1/teams/${team.id}/share',
              ),
            );
          },
        ),
        if (team.soyMiembro)
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: currentUserId == null ? null : () async {
                  final updated = await context.push<bool>(
                    '/team-settings/${team.id}',
                    extra: {
                      'team': team,
                      'currentUserId': currentUserId,
                    },
                  );
                  if (updated == true) _loadTeam();
                },
              );
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image/Logo
            if (team.logo.startsWith('http'))
              Image.network(team.logo, fit: BoxFit.cover)
            else
              Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    team.logo.isNotEmpty ? team.logo : '🛡️',
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            // Team Info Overlay
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      team.sportName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (team.isRecruiting)
                    Row(
                      children: [
                        const Icon(Icons.person_add, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'RECLUTANDO',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(TeamEntity team, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatCard('Jugadores', '${team.currentMembers}/${team.maxMembers}', Icons.people_outline),
        const SizedBox(width: 8),
        BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            final count = state is MatchesLoaded ? state.matches.length : 0;
            return _buildStatCard('Partidos', '$count', Icons.sports_soccer_outlined);
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            int wins = 0;
            if (state is MatchesLoaded) {
              wins = state.matches.where((m) {
                final isTeamA = m.idEquipoA == team.id;
                final ourScore = isTeamA ? (m.resultadoGolesACapA ?? 0) : (m.resultadoGolesBCapA ?? 0);
                final oppScore = isTeamA ? (m.resultadoGolesBCapA ?? 0) : (m.resultadoGolesACapA ?? 0);
                return ourScore > oppScore;
              }).length;
            }
            return _buildStatCard('Victorias', '$wins', Icons.emoji_events_outlined);
          },
        ),
      ],
    );
  }

  Widget _buildTabs(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _buildTabButton('roster', 'Plantilla'),
          _buildTabButton('history', 'Historial'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.border : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabName, String label) {
    final isSelected = _activeTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRosterTab(TeamEntity team, ColorScheme colorScheme) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_membersFuture, _requestsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final members = snapshot.hasData
            ? (snapshot.data![0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList()
            : <Map<String, dynamic>>[];

        final requests = snapshot.hasData
            ? (snapshot.data![1] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList()
            : <Map<String, dynamic>>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            if (team.soyMiembro && requests.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Solicitudes Pendientes',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: colorScheme.outlineVariant),
                    ...requests.map((req) => _buildPendingRequestRow(req, colorScheme)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Miembros del Equipo (${members.length})',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colorScheme.outlineVariant),
                  if (members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No hay miembros en este equipo todavía.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                      ),
                    )
                  else
                    ...members.map((member) => _buildMemberRow(member, colorScheme)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildPendingRequestRow(Map<String, dynamic> req, ColorScheme colorScheme) {
    final name = req['nombre_usuario'] ?? 'Usuario';
    final photo = req['url_foto_perfil'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: photo.isNotEmpty && photo.startsWith('http')
                ? NetworkImage(photo) as ImageProvider
                : null,
            child: photo.isEmpty || !photo.startsWith('http')
                ? Text('👤', style: TextStyle(color: colorScheme.onSurface))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: () async {
              final userId = req['fk_id_usuario'] ?? req['id_usuario'];
              if (userId == null) return;
              final result = await sl<RespondToJoinRequestUseCase>().call(widget.teamId, userId, true);
              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitud aceptada correctamente.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  setState(() {
                    _loadTeam();
                  });
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () async {
              final userId = req['fk_id_usuario'] ?? req['id_usuario'];
              if (userId == null) return;
              final result = await sl<RespondToJoinRequestUseCase>().call(widget.teamId, userId, false);
              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitud rechazada correctamente.'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  setState(() {
                    _loadTeam();
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(Map<String, dynamic> member, ColorScheme colorScheme) {
    final name = member['nombre_usuario'] ?? 'Usuario';
    final photo = member['url_foto_perfil'] ?? '';
    final role = member['rol_equipo'] ?? 'Jugador';

    final roleColor = role == 'Capitán' || role == 'Capitan' || role == 'captain'
        ? AppColors.primary
        : role == 'Co-Capitán'
            ? AppColors.warning
            : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: photo.isNotEmpty && photo.startsWith('http')
                ? NetworkImage(photo) as ImageProvider
                : null,
            child: photo.isEmpty || !photo.startsWith('http')
                ? Text('👤', style: TextStyle(color: colorScheme.onSurface))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ColorScheme colorScheme) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is MatchesError) {
          return Center(child: Text(state.message));
        } else if (state is MatchesLoaded) {
          return MatchHistoryList(
            matches: state.matches,
            perspectiveTeamId: widget.teamId,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
