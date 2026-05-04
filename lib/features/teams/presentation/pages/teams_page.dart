import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
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

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el BLoC y cargamos los equipos inmediatamente
    return BlocProvider(
      create: (_) => sl<TeamsBloc>()..add(LoadTeamsEvent()),
      child: const _TeamsView(),
    );
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
  int? _filterMaxMembers; // null es "Cualquiera"
  bool _filterOnlyRecruiting = true;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<TeamEntity> _cachedTeams = [];
  List<SportEntity> _cachedSports = [];

  @override
  void initState() {
    super.initState();
    
    // Inicializar caché desde el estado actual del BLoC si ya existe
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
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filtros Avanzados',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Deportes',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModalChip(
                        label: 'Todos',
                        isSelected: _selectedFilter == 'Todos',
                        setModalState: setModalState,
                        onTap: () {
                          setState(() => _selectedFilter = 'Todos');
                        },
                      ),
                      ...sports.map((sport) {
                        final isSelected = _selectedFilter == sport.name;
                        return _buildModalChip(
                          label: sport.name,
                          isSelected: isSelected,
                          setModalState: setModalState,
                          onTap: () {
                            setState(() {
                              _selectedFilter = sport.name;
                              _recentSports.remove(sport.name);
                              _recentSports.insert(0, sport.name);
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Capacidad máxima de jugadores',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      _buildModalChip(
                        label: '5 Jugadores',
                        isSelected: _filterMaxMembers == 5,
                        setModalState: setModalState,
                        onTap: () => setState(() => _filterMaxMembers = 5),
                      ),
                      _buildModalChip(
                        label: '7 Jugadores',
                        isSelected: _filterMaxMembers == 7,
                        setModalState: setModalState,
                        onTap: () => setState(() => _filterMaxMembers = 7),
                      ),
                      _buildModalChip(
                        label: '11 Jugadores',
                        isSelected: _filterMaxMembers == 11,
                        setModalState: setModalState,
                        onTap: () => setState(() => _filterMaxMembers = 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solo equipos reclutando',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _filterOnlyRecruiting,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setModalState(() {
                            _filterOnlyRecruiting = val;
                          });
                          setState(() {
                            _filterOnlyRecruiting = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(modalContext),
                      child: const Text(
                        'Aplicar Filtros',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalChip({
    required String label,
    required bool isSelected,
    required void Function(void Function()) setModalState,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: colorScheme.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.transparent : Colors.grey.shade300),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        setModalState(() {
          onTap();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MatchDaySearchBar(
                controller: _searchController,
                hintText: 'Buscar equipos...',
              ),
            ),
            const SizedBox(height: 16),
            
            // FILTERS & LOADING BAR
            BlocConsumer<TeamsBloc, TeamsState>(
              listener: (context, state) {
                if (state is TeamsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
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
                final List<String> dynamicFilters = _getDynamicFilters(_cachedSports);
                
                return Column(
                  children: [
                    MatchDayFilterChips<String>(
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
                    ),
                    MatchDayLoadingBar(
                      isLoading: state is TeamsLoading,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    ),
                  ],
                );
              },
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  final state = context.watch<TeamsBloc>().state;
                  
                  final teamsToShow = state is TeamsLoaded ? state.teams : _cachedTeams;

                  if (state is TeamsLoading && teamsToShow.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final filteredTeams = teamsToShow.where((team) {
                    final matchesSport = _selectedFilter == 'Todos' || (team.sportName.toLowerCase() == _selectedFilter.toLowerCase());
                    final matchesSearch = _searchQuery.isEmpty || team.name.toLowerCase().contains(_searchQuery);
                    final matchesMembers = _filterMaxMembers == null || team.maxMembers == _filterMaxMembers;
                    final matchesRecruiting = !_filterOnlyRecruiting || team.isRecruiting;
                    return matchesSport && matchesSearch && matchesMembers && matchesRecruiting;
                  }).toList();

                  if (filteredTeams.isEmpty && state is! TeamsLoading) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TeamsBloc>().add(LoadTeamsEvent());
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Text(
                              _cachedTeams.isEmpty
                                  ? 'No hay equipos disponibles en este momento.'
                                  : 'No se encontraron equipos para estos filtros.',
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TeamsBloc>().add(LoadTeamsEvent());
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
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
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/crear-equipo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Crear Equipo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
