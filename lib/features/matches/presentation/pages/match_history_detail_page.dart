import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';

class MatchHistoryDetailPage extends StatefulWidget {
  final int matchId;
  const MatchHistoryDetailPage({super.key, required this.matchId});

  @override
  State<MatchHistoryDetailPage> createState() => _MatchHistoryDetailPageState();
}

class _MatchHistoryDetailPageState extends State<MatchHistoryDetailPage> {
  List<MatchPlayer> _players = [];
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    final repository = sl<IMatchesRepository>();
    final result = await repository.getMatchPlayers(widget.matchId);
    if (mounted) {
      result.fold(
        (_) => setState(() => _isLoadingPlayers = false),
        (players) => setState(() {
          _players = players;
          _isLoadingPlayers = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchDetailsEvent(widget.matchId)),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Resumen del Encuentro',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface),
          ),
        ),
        body: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            if (state is MatchesLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is MatchesError) {
              return Center(child: Text(state.message));
            } else if (state is MatchDetailsLoaded) {
              return _buildContent(state.match, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Marcador Final
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Text(
                  'Resultado Final',
                  style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTeamInfo(context, match.nombreEquipoA ?? 'Equipo A', match.logoEquipoA, isDark),
                    Row(
                      children: [
                        Text('$golesA', style: TextStyle(color: colorScheme.onSurface, fontSize: 48, fontWeight: FontWeight.bold)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('-', style: TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                        Text('$golesB', style: TextStyle(color: colorScheme.onSurface, fontSize: 48, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    _buildTeamInfo(context, match.nombreEquipoB ?? 'Equipo B', match.logoEquipoB, isDark),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Encuentro Finalizado',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detalles del Partido
          _buildInfoCard(match, isDark),
          const SizedBox(height: 20),

          // Jugadores
          _buildPlayersSection(isDark, match),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context, String name, String? logo, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.dividerColor),
          ),
          child: ClipOval(
            child: logo != null 
                ? Image.network(
                    logo, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.sports_soccer, size: 24, color: Colors.grey)),
                  ) 
                : const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _infoRow(context, Icons.calendar_today, 'Fecha', DateFormat('EEEE d MMMM', 'es_VE').format(match.fechaInicioEstimada), isDark),
          Divider(color: theme.dividerColor, height: 24),
          _infoRow(context, Icons.location_on_outlined, 'Cancha', match.nombreCancha ?? 'Cancha', isDark),
          Divider(color: theme.dividerColor, height: 24),
          _infoRow(context, Icons.sports_soccer, 'Deporte', match.sportName ?? 'Fútbol', isDark),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textMuted, fontSize: 11)),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayersSection(bool isDark, MatchEntity match) {
    if (_isLoadingPlayers) return const Center(child: CircularProgressIndicator());
    if (_players.isEmpty) return const SizedBox.shrink();

    final teamAPlayers = _players.where((p) => p.idEquipo == match.idEquipoA).toList();
    final teamBPlayers = _players.where((p) => p.idEquipo == match.idEquipoB).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alineaciones', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildTeamPlayersList(match.nombreEquipoA ?? 'Equipo A', teamAPlayers, isDark),
        const SizedBox(height: 12),
        _buildTeamPlayersList(match.nombreEquipoB ?? 'Equipo B', teamBPlayers, isDark),
      ],
    );
  }

  Widget _buildTeamPlayersList(String teamName, List<MatchPlayer> players, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(teamName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...players.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  backgroundImage: (p.urlFotoPerfil != null && p.urlFotoPerfil!.startsWith('http')) 
                      ? NetworkImage(p.urlFotoPerfil!) 
                      : null,
                  child: (p.urlFotoPerfil == null || !p.urlFotoPerfil!.startsWith('http')) ? Icon(Icons.person, size: 12, color: isDark ? Colors.white70 : Colors.black54) : null,
                ),
                const SizedBox(width: 10),
                Text(p.nombreUsuario, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
