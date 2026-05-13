import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../widgets/leaderboard_skeleton.dart';
import '../../../teams/presentation/bloc/teams_bloc.dart';
import '../../../teams/presentation/bloc/teams_state.dart';
import '../../../../core/widgets/matchday_filter_chips.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int? _selectedSportId;
  String _selectedPeriod = 'all';

  final List<Map<String, String>> _periods = [
    {'label': 'Todo el tiempo', 'value': 'all'},
    {'label': 'Este Mes', 'value': 'month'},
    {'label': 'Este Año', 'value': 'year'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    context.read<LeaderboardBloc>().add(
      LoadLeaderboardEvent(sportId: _selectedSportId, period: _selectedPeriod),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(isDark),
              const SizedBox(height: 16),
              _buildFilters(context),
              const SizedBox(height: 8),
              Expanded(child: _buildMainContent(state, isDark)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ranking',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const Icon(
            Icons.military_tech_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sports Filter
        BlocBuilder<TeamsBloc, TeamsState>(
          builder: (context, state) {
            final sports = state is TeamsLoaded ? state.sports : [];
            return MatchDayFilterChips<int?>(
              options: [
                const FilterOption<int?>(label: 'Todos', value: null),
                ...sports.map(
                  (s) => FilterOption<int?>(label: s.name, value: s.id),
                ),
              ],
              selectedValue: _selectedSportId,
              onSelected: (val) {
                setState(() => _selectedSportId = val);
                _loadLeaderboard();
              },
            );
          },
        ),
        const SizedBox(height: 8),
        // Period Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(period['label']!),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedPeriod = period['value']!);
                      _loadLeaderboard();
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(LeaderboardState state, bool isDark) {
    if (state is LeaderboardLoading || state is LeaderboardInitial) {
      return const LeaderboardSkeleton();
    } else if (state is LeaderboardError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    } else if (state is LeaderboardLoaded) {
      if (state.leaderboard.isEmpty) return _buildEmptyState(isDark);

      final theme = Theme.of(context);
      final surfaceColor = theme.colorScheme.surface;

      return RefreshIndicator(
        onRefresh: () async => _loadLeaderboard(),
        color: AppColors.primary,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildPodium(state.leaderboard, isDark, surfaceColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'CLASIFICACIÓN GENERAL',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...state.leaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final team = entry.value;
              return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _buildLeaderboardTile(team, isDark),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.1, end: 0);
            }),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPodium(
    List<LeaderboardEntryEntity> teams,
    bool isDark,
    Color surfaceColor,
  ) {
    if (teams.isEmpty) return const SizedBox.shrink();
    final first = teams[0];
    final second = teams.length > 1 ? teams[1] : null;
    final third = teams.length > 2 ? teams[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2do Lugar
        if (second != null)
          Expanded(
            child: _buildPodiumColumn(
              second,
              2,
              const Color(0xFFC0C0C0),
              110,
              isDark,
              surfaceColor,
            ),
          ),
        if (second != null) const SizedBox(width: 8),

        // 1er Lugar
        Expanded(
          child: _buildPodiumColumn(
            first,
            1,
            const Color(0xFFFFD700),
            140,
            isDark,
            surfaceColor,
          ),
        ),

        // 3er Lugar
        if (third != null) const SizedBox(width: 8),
        if (third != null)
          Expanded(
            child: _buildPodiumColumn(
              third,
              3,
              const Color(0xFFCD7F32),
              95,
              isDark,
              surfaceColor,
            ),
          ),
      ],
    );
  }

  Widget _buildPodiumColumn(
    LeaderboardEntryEntity team,
    int position,
    Color color,
    double height,
    bool isDark,
    Color surfaceColor,
  ) {
    final double avatarSize = position == 1 ? 90 : 75;
    final double iconSize = position == 1 ? 48 : 38;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar con resplandor
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: CircleAvatar(
                  backgroundColor: surfaceColor,
                  backgroundImage: team.urlLogoEquipo != null
                      ? NetworkImage(team.urlLogoEquipo!)
                      : null,
                  child: team.urlLogoEquipo == null
                      ? Icon(Icons.shield, color: color, size: iconSize)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: surfaceColor, width: 2),
                  ),
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Pedestal
        Container(
          width: double.infinity,
          height: height + 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              Icon(
                position == 1 ? Icons.emoji_events : Icons.military_tech,
                color: color,
                size: position == 1 ? 42 : 34,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  team.nombreEquipo,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: position == 1 ? 14 : 12,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${team.puntosTotales} pts',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntryEntity team, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${team.posicion}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: team.posicion <= 3
                    ? _getRankColor(team.posicion)
                    : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage: team.urlLogoEquipo != null
                ? NetworkImage(team.urlLogoEquipo!)
                : null,
            child: team.urlLogoEquipo == null
                ? const Icon(Icons.shield, size: 20)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.nombreEquipo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${team.deporte} • ${team.victorias} victorias',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${team.puntosTotales}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'PTS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.military_tech_outlined,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
          const SizedBox(height: 24),
          Text(
            'Sin rivales a la vista',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Aún no hay equipos compitiendo en esta liga. ¡Sé el primero en llegar a la cima!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
