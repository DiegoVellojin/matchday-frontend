import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/usecases/get_team_by_id_usecase.dart';
import '../../application/usecases/get_team_members_usecase.dart';
import '../../application/usecases/get_pending_requests_usecase.dart';
import '../../application/usecases/request_join_team_usecase.dart';
import '../../application/usecases/respond_to_join_request_usecase.dart';
import '../../domain/entities/team_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
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
    _teamFuture = sl<GetTeamByIdUseCase>().call(widget.teamId).then((result) => result.fold(
      (failure) => throw Exception(failure.message),
      (team) => team,
    ));

    _membersFuture = sl<GetTeamMembersUseCase>().call(widget.teamId).then((result) => result.fold(
      (failure) => [],
      (members) => members,
    ));

    _requestsFuture = sl<GetPendingRequestsUseCase>().call(widget.teamId).then((result) => result.fold(
      (failure) => [],
      (requests) => requests,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchesEvent(teamId: widget.teamId, status: 'completada')),
      child: FutureBuilder<TeamEntity>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const TeamDashboardSkeleton();
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString(), theme);
          if (!snapshot.hasData) return const Center(child: Text('Equipo no encontrado.'));

          final team = snapshot.data!;
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildSliverAppBar(context, team, isDark),
              ],
              body: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    children: [
                      _buildStatsRow(team, isDark),
                      const SizedBox(height: 32),
                      _buildModernTabs(isDark),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _activeTab == 'roster'
                            ? _buildRosterTab(team, isDark)
                            : _buildHistoryTab(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: !team.soyMiembro ? _buildJoinButton(team) : null,
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeamEntity team, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => context.canPop() ? context.pop() : context.go('/hub'),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () => SharePlus.instance.share(
            ShareParams(text: '¡Únete a mi equipo ${team.name} en MatchDay! 🏆 https://matchday.app/teams/${team.id}'),
          ),
        ),
        if (team.soyMiembro)
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                  child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                ),
                onPressed: currentUserId == null ? null : () async {
                  final updated = await context.push<bool>(
                    '/team-settings/${team.id}',
                    extra: {'team': team, 'currentUserId': currentUserId},
                  );
                  if (updated == true) _loadTeam();
                },
              );
            },
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -1,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'team_logo_${team.id}',
              child: team.logo.startsWith('http')
                  ? Image.network(team.logo, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      child: Center(child: Text(team.logo.isNotEmpty ? team.logo : '🛡️', style: const TextStyle(fontSize: 100))),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              child: _buildRecruitingBadge(team.isRecruiting),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitingBadge(bool isRecruiting) {
    if (!isRecruiting) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add_rounded, size: 14, color: Colors.black),
          SizedBox(width: 6),
          Text('RECLUTANDO', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    ).animate().shimmer(duration: 2.seconds);
  }

  Widget _buildStatsRow(TeamEntity team, bool isDark) {
    return Row(
      children: [
        _buildStatCard('Jugadores', '${team.currentMembers}/${team.maxMembers}', Icons.people_rounded, isDark),
        const SizedBox(width: 12),
        BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            final count = state is MatchesLoaded ? state.matches.length : 0;
            return _buildStatCard('Partidos', '$count', Icons.sports_soccer_rounded, isDark);
          },
        ),
        const SizedBox(width: 12),
        _buildStatCard('Nivel', 'PRO', Icons.bolt_rounded, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            Text(label, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabButton('roster', 'Plantilla', isDark),
          _buildTabButton('history', 'Historial', isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName, String label, bool isDark) {
    final isSelected = _activeTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabName),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.black26 : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRosterTab(TeamEntity team, bool isDark) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_membersFuture, _requestsFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        
        final members = snapshot.hasData ? (snapshot.data![0] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
        final requests = snapshot.hasData ? (snapshot.data![1] as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (team.soyMiembro && requests.isNotEmpty) ...[
              _buildSectionHeader('Solicitudes Pendientes', requests.length),
              const SizedBox(height: 16),
              ...requests.map((req) => _buildRequestCard(req, isDark)),
              const SizedBox(height: 32),
            ],
            _buildSectionHeader('Miembros del Equipo', members.length),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildMemberCard(members[index], isDark),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
        const SizedBox(width: 12),
        Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member, bool isDark) {
    final role = member['rol_equipo'] ?? 'Jugador';
    final isCaptain = role.toString().toLowerCase().contains('capit');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
            backgroundImage: (member['url_foto_perfil']?.toString().startsWith('http') ?? false)
                ? NetworkImage(member['url_foto_perfil'])
                : null,
            child: !(member['url_foto_perfil']?.toString().startsWith('http') ?? false)
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['nombre_usuario'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(isCaptain ? 'Líder de equipo' : 'Miembro activo', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          _buildRoleBadge(role, isCaptain),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: (req['url_foto_perfil']?.toString().startsWith('http') ?? false) ? NetworkImage(req['url_foto_perfil']) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(req['nombre_usuario'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () => _respondRequest(req, true),
            icon: const Icon(Icons.check_circle, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () => _respondRequest(req, false),
            icon: const Icon(Icons.cancel, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role, bool isCaptain) {
    final color = isCaptain ? AppColors.primary : Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildJoinButton(TeamEntity team) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          onPressed: () async {
            final result = await sl<RequestJoinTeamUseCase>().call(team.id);
            result.fold(
              (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${f.message}'))),
              (_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Solicitud enviada!')));
                _loadTeam();
              },
            );
          },
          child: const Text('SOLICITAR UNIRSE AL EQUIPO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)));
        if (state is MatchesLoaded) return MatchHistoryList(matches: state.matches, perspectiveTeamId: widget.teamId);
        return const Center(child: Text('Sin historial de partidos.'));
      },
    );
  }

  void _respondRequest(Map<String, dynamic> req, bool accept) async {
    final userId = req['fk_id_usuario'] ?? req['id_usuario'];
    final res = await sl<RespondToJoinRequestUseCase>().call(widget.teamId, userId, accept);
    res.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accept ? 'Aceptado' : 'Rechazado'), backgroundColor: accept ? AppColors.primary : Colors.redAccent));
        _loadTeam();
      }
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 60),
          const SizedBox(height: 16),
          Text('Vaya, algo salió mal', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => setState(() => _loadTeam()), child: const Text('REINTENTAR')),
        ],
      ),
    );
  }
}
