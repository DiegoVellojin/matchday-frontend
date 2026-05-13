import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/teams_bloc.dart';
import '../bloc/teams_event.dart';
import '../bloc/teams_state.dart';
import '../../domain/entities/sport_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../widgets/team_discovery_card.dart';
import '../../../../core/widgets/matchday_search_bar.dart';
import '../../../../core/widgets/matchday_filter_chips.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';
import '../widgets/team_discovery_skeleton.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _TeamsView();
  }
}

class _TeamsView extends StatefulWidget {
  const _TeamsView();

  @override
  State<_TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<_TeamsView> {
  String _selectedFilter = 'Todos';
  final List<String> _recentSports = [];
  int? _filterMaxMembers;
  bool _filterOnlyRecruiting = true;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<TeamEntity> _cachedTeams = [];
  List<SportEntity> _cachedSports = [];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TeamsBloc>().state;
    if (currentState is TeamsLoaded) {
      _cachedTeams = currentState.teams;
      _cachedSports = currentState.sports;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getDynamicFilters(List<SportEntity> sportsFromState) {
    final allSportNames = sportsFromState.map((s) => s.name).toList();
    final remainingSports = allSportNames
        .where((s) => !_recentSports.contains(s))
        .toList();
    return ['Todos', ..._recentSports, ...remainingSports];
  }

  void _openFiltersBottomSheet(BuildContext context, List<SportEntity> sports) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colorScheme = Theme.of(context).colorScheme;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros Avanzados',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedFilter = 'Todos';
                              _filterMaxMembers = null;
                              _filterOnlyRecruiting = false;
                            });
                          },
                          child: const Text('Limpiar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildFilterSectionTitle('Deportes', isDark),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModalChip(
                          label: 'Todos',
                          isSelected: _selectedFilter == 'Todos',
                          setModalState: setModalState,
                          onTap: () => setState(() => _selectedFilter = 'Todos'),
                        ),
                        ...sports.map((sport) => _buildModalChip(
                          label: sport.name,
                          isSelected: _selectedFilter == sport.name,
                          setModalState: setModalState,
                          onTap: () {
                            setState(() {
                              _selectedFilter = sport.name;
                              _recentSports.remove(sport.name);
                              _recentSports.insert(0, sport.name);
                            });
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildFilterSectionTitle('Capacidad máxima', isDark),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModalChip(
                          label: 'Cualquiera',
                          isSelected: _filterMaxMembers == null,
                          setModalState: setModalState,
                          onTap: () => setState(() => _filterMaxMembers = null),
                        ),
                        ...[5, 7, 11, 22].map((m) => _buildModalChip(
                          label: '$m Jugadores',
                          isSelected: _filterMaxMembers == m,
                          setModalState: setModalState,
                          onTap: () => setState(() => _filterMaxMembers = m),
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solo reclutando',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Mostrar solo equipos con cupos',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _filterOnlyRecruiting,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() => _filterOnlyRecruiting = val);
                              setState(() => _filterOnlyRecruiting = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(modalContext),
                        child: const Text('APLICAR FILTROS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildModalChip({
    required String label,
    required bool isSelected,
    required void Function(void Function()) setModalState,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: isDark ? Colors.black26 : Colors.grey[100],
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : (isDark ? Colors.grey[300] : Colors.black87),
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
      onSelected: (_) {
        setModalState(() => onTap());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Descubrir Equipos',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                const Icon(Icons.explore_outlined, color: AppColors.primary, size: 26),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MatchDaySearchBar(
              controller: _searchController,
              hintText: 'Buscar equipos...',
            ),
          ),
          const SizedBox(height: 12),
          
          BlocBuilder<TeamsBloc, TeamsState>(
            builder: (context, state) {
              final List<String> dynamicFilters = _getDynamicFilters(_cachedSports);
              return MatchDayFilterChips<String>(
                options: dynamicFilters.map((f) => FilterOption(label: f, value: f)).toList(),
                selectedValue: _selectedFilter,
                onSelected: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedFilter = val;
                    if (val != 'Todos') {
                      _recentSports.remove(val);
                      _recentSports.insert(0, val);
                    }
                  });
                },
                onAdvancedFiltersPressed: () => _openFiltersBottomSheet(context, _cachedSports),
              );
            },
          ),
          
          BlocBuilder<TeamsBloc, TeamsState>(
            builder: (context, state) => MatchDayLoadingBar(
              isLoading: state is TeamsLoading,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            ),
          ),

          Expanded(
            child: BlocConsumer<TeamsBloc, TeamsState>(
              listener: (context, state) {
                if (state is TeamsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                  );
                } else if (state is TeamJoinRequestSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
                  );
                }
                if (state is TeamsLoaded) {
                  setState(() {
                    _cachedTeams = state.teams;
                    _cachedSports = state.sports;
                  });
                }
              },
              builder: (context, state) {
                final teamsToShow = state is TeamsLoaded ? state.teams : _cachedTeams;

                if (state is TeamsLoading && teamsToShow.isEmpty) {
                  return const TeamDiscoverySkeleton();
                }

                final filteredTeams = teamsToShow.where((team) {
                  final matchesSport = _selectedFilter == 'Todos' || (team.sportName.toLowerCase() == _selectedFilter.toLowerCase());
                  final matchesSearch = _searchQuery.isEmpty || team.name.toLowerCase().contains(_searchQuery);
                  final matchesMembers = _filterMaxMembers == null || team.maxMembers == _filterMaxMembers;
                  final matchesRecruiting = !_filterOnlyRecruiting || team.isRecruiting;
                  return matchesSport && matchesSearch && matchesMembers && matchesRecruiting;
                }).toList();

                if (filteredTeams.isEmpty && state is! TeamsLoading) {
                  return _buildEmptyState(isDark);
                }

                return RefreshIndicator(
                  onRefresh: () async => context.read<TeamsBloc>().add(LoadTeamsEvent()),
                  color: AppColors.primary,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      return TeamDiscoveryCard(
                        team: team,
                        onRequestJoin: () {
                          context.read<TeamsBloc>().add(RequestJoinTeamEvent(teamId: team.id));
                        },
                      ).animate()
                       .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                       .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'teams_fab',
        onPressed: () => context.push('/crear-equipo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, weight: 900),
        label: const Text('CREAR EQUIPO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          const Text('No encontramos equipos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Prueba ajustando los filtros o realizando otra búsqueda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
