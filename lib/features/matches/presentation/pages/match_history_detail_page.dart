import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Marcador Final Dinámico
          _buildOfficialScoreCard(golesA, golesB, match.nombreEquipoA ?? 'Equipo A', isDark)
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOutBack)
            .fadeIn()
            .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 20),

          // Detalles del Partido
          _buildInfoCard(match, isDark)
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),

          // Jugadores
          _buildPlayersSection(isDark, match)
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 40),
        ],
      ),
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
  Widget _buildOfficialScoreCard(int f, int c, String teamName, bool isDark) {
    final style = _getResultStyle(f, c);
    final Color mainColor = style['color'] as Color;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.15),
            mainColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mainColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style['icon'] as IconData, color: mainColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  style['label'] as String,
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildScoreDigit(f, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('-', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: mainColor.withValues(alpha: 0.5))),
              ),
              _buildScoreDigit(c, isDark),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Resultado Final Confirmado',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark) {
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, dynamic> _getResultStyle(int f, int c) {
    if (f > c) {
      return {
        'label': 'VICTORIA',
        'color': Colors.greenAccent,
        'icon': Icons.emoji_events,
      };
    } else if (f < c) {
      return {
        'label': 'DERROTA',
        'color': Colors.redAccent,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'label': 'EMPATE',
        'color': Colors.amberAccent,
        'icon': Icons.drag_handle,
      };
    }
  }
}
