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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESUMEN DEL ENCUENTRO',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colorScheme.onSurface, letterSpacing: -0.5),
              ),
              Text(
                'HISTORIAL FINALIZADO',
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ],
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
          const SizedBox(height: 24),

          // Detalles del Partido
          _buildInfoCard(match, isDark)
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(context, Icons.calendar_today_rounded, 'FECHA', DateFormat("EEEE d 'de' MMMM", 'es_VE').format(match.fechaInicioEstimada.toLocal()).toUpperCase(), isDark),
          const SizedBox(height: 20),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 20),
          _infoRow(context, Icons.location_on_rounded, 'CANCHA', (match.nombreCancha ?? 'SEDE NO REGISTRADA').toUpperCase(), isDark),
          const SizedBox(height: 20),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 20),
          _infoRow(context, Icons.sports_soccer_rounded, 'DEPORTE', (match.sportName ?? 'FÚTBOL').toUpperCase(), isDark),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text(
                value, 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersSection(bool isDark, MatchEntity match) {
    if (_isLoadingPlayers) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_players.isEmpty) return const SizedBox.shrink();

    final teamAPlayers = _players.where((p) => p.idEquipo == match.idEquipoA).toList();
    final teamBPlayers = _players.where((p) => p.idEquipo == match.idEquipoB).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALINEACIONES', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        _buildTeamPlayersList(match.nombreEquipoA ?? 'EQUIPO A', teamAPlayers, isDark),
        const SizedBox(height: 16),
        _buildTeamPlayersList(match.nombreEquipoB ?? 'EQUIPO B', teamBPlayers, isDark),
      ],
    );
  }

  Widget _buildTeamPlayersList(String teamName, List<MatchPlayer> players, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                teamName.toUpperCase(), 
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...players.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: isDark ? Colors.black26 : Colors.grey[100],
                    backgroundImage: (p.urlFotoPerfil != null && p.urlFotoPerfil!.startsWith('http')) 
                        ? NetworkImage(p.urlFotoPerfil!) 
                        : null,
                    child: (p.urlFotoPerfil == null || !p.urlFotoPerfil!.startsWith('http')) 
                      ? Icon(Icons.person_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black45) 
                      : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    p.nombreUsuario, 
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                if (p.idUsuario == widget.matchId) // Optional: highlight current user if needed, but matchId is not userId
                  const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style['icon'] as IconData, color: mainColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  (style['label'] as String).toUpperCase(),
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreDigit(f, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(':', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: mainColor.withValues(alpha: 0.3))),
              ),
              _buildScoreDigit(c, isDark),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primary, size: 14),
              const SizedBox(width: 8),
              const Text(
                'RESULTADO FINAL CONFIRMADO',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark) {
    return Container(
      width: 76,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2),
      ),
    );
  }

  Map<String, dynamic> _getResultStyle(int f, int c) {
    if (f > c) {
      return {
        'label': 'Victoria',
        'color': Colors.greenAccent,
        'icon': Icons.emoji_events_rounded,
      };
    } else if (f < c) {
      return {
        'label': 'Derrota',
        'color': Colors.redAccent,
        'icon': Icons.trending_down_rounded,
      };
    } else {
      return {
        'label': 'Empate',
        'color': Colors.amberAccent,
        'icon': Icons.drag_handle_rounded,
      };
    }
  }
}
