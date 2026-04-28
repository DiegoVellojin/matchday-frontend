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

  final List<Map<String, dynamic>> matchHistory = [];

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
      body: FutureBuilder<TeamEntity>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Equipo no encontrado.',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }

          final team = snapshot.data!;

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, team, colorScheme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _activeTab == 'roster'
                        ? _buildRosterTab(team, colorScheme)
                        : _buildHistoryTab(colorScheme),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TeamEntity team, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.primary),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '¡Únete a mi equipo ${team.name} en MatchDay! ⚽🏆 Descarga la app y búscanos.',
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Team Hero
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: team.logo.startsWith('http')
                  ? Image.network(team.logo, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        team.logo.isNotEmpty ? team.logo : '🛡️',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            team.name,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            team.sportName,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (team.isRecruiting)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '¡Buscando nuevos miembros!',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStatCard('Jugadores', '${team.currentMembers}/${team.maxMembers}', colorScheme),
              const SizedBox(width: 8),
              _buildStatCard('Partidos', '0', colorScheme),
              const SizedBox(width: 8),
              _buildStatCard('Victorias', '0', colorScheme),
              if (team.soyMiembro) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Módulo de Pagos próximamente.')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.attach_money, color: AppColors.warning, size: 20),
                          SizedBox(height: 4),
                          Text(
                            'Pagos',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton('roster', 'Plantilla', colorScheme),
                _buildTabButton('history', 'Historial', colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabName, String label, ColorScheme colorScheme) {
    final isSelected = _activeTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tabName;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
            _buildActionSection(team, colorScheme),
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

  Widget _buildActionSection(TeamEntity team, ColorScheme colorScheme) {
    if (team.soyMiembro) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Eres miembro activo de este equipo.',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
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
          'Solicitar Unirse',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
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
    if (matchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.sports_soccer, color: colorScheme.onSurfaceVariant, size: 48),
              const SizedBox(height: 16),
              Text(
                'No hay historial de partidos todavía.',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: matchHistory.map((match) => _buildMatchCard(match, colorScheme)).toList(),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, ColorScheme colorScheme) {
    final isWon = match['won'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    match['date'],
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWon
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isWon ? 'Ganado' : 'Perdido',
                  style: TextStyle(
                    color: isWon ? AppColors.primary : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: const Text('⚽'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Elite Strikers',
                            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Nuestro Equipo',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${match['ourScore']} - ${match['opponentScore']}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            match['opponent'],
                            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Rival',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: const Text('⚽'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
