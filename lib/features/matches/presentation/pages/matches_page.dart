import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../../../core/widgets/matchday_search_bar.dart';
import '../../../../core/widgets/matchday_filter_chips.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teams_discovery/domain/entities/sport_entity.dart';
import '../../../catalogs/application/usecases/get_sports_usecase.dart' as cat_usecase;
import '../../../catalogs/domain/entities/region_entity.dart';
import '../../../catalogs/domain/entities/cancha_entity.dart';
import '../../../catalogs/application/usecases/get_regions_usecase.dart';
import '../../../catalogs/application/usecases/get_canchas_usecase.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  int? selectedSportId;
  int? selectedRegionId;
  int? selectedCanchaId;
  DateTime? selectedDate;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SportEntity> _sports = [];
  List<RegionEntity> _regions = [];
  List<CanchaEntity> _canchas = [];
  
  bool _isMyMatchesView = false;
  bool _isLoadingCatalogs = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_VE', null);
    _loadCatalogs();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadCatalogs() async {
    final sportsRes = await sl<cat_usecase.GetSportsUseCase>().call();
    final regionsRes = await sl<GetRegionsUseCase>().call();
    final canchasRes = await sl<GetCanchasUseCase>().call();

    if (mounted) {
      setState(() {
        _sports = sportsRes.getOrElse((_) => []);
        _regions = regionsRes.getOrElse((_) => []);
        _canchas = canchasRes.getOrElse((_) => []);
        _isLoadingCatalogs = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MatchDaySearchBar(
                    controller: _searchController,
                    hintText: 'Buscar partidos...',
                  ),
                ),
                const SizedBox(height: 16),
                _buildViewSelector(isDark),
                const SizedBox(height: 16),
                _isLoadingCatalogs 
                  ? const LinearProgressIndicator(color: AppColors.primary)
                  : MatchDayFilterChips<int?>(
                      options: [
                        const FilterOption(label: 'Todos', value: null),
                        ..._sports.map((s) => FilterOption(label: s.name, value: s.id)),
                      ],
                      selectedValue: selectedSportId,
                      onSelected: (val) {
                        setState(() => selectedSportId = val);
                        _applyFilters();
                      },
                      onAdvancedFiltersPressed: () => _openFiltersBottomSheet(context),
                    ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildBody(state, isDark),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/crear-partido'),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      );
  }

  Widget _buildBody(MatchesState state, bool isDark) {
    if (state is MatchesLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is MatchesError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    } else if (state is MatchesLoaded) {
      final profileState = context.read<ProfileBloc>().state;
      int? currentUserId;
      if (profileState is ProfileLoaded) {
        currentUserId = profileState.profile.id;
      }

      final filteredMatches = state.matches.where((m) {
        // Filtro por tipo de vista (Mis Partidos vs Ofertas)
        if (_isMyMatchesView) {
          if (m.idUsuarioOrg != currentUserId) return false;
        } else {
          // En ofertas, tal vez no quiero ver los míos?
          // El usuario dijo "separar", así que en ofertas mostraré los de otros.
          if (m.idUsuarioOrg == currentUserId) return false;
        }

        final matchesSearch = _searchQuery.isEmpty ||
            m.id.toString().contains(_searchQuery) ||
            (m.sportName ?? 'Deporte').toLowerCase().contains(_searchQuery);
        return matchesSearch;
      }).toList();

      if (filteredMatches.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isMyMatchesView ? Icons.sports_soccer : Icons.search_off,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                _isMyMatchesView 
                  ? 'Aún no has organizado ningún partido.' 
                  : 'No hay ofertas disponibles.',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        itemCount: filteredMatches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final match = filteredMatches[index];
          return _buildMatchCard(match, isDark, currentUserId);
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildViewSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _buildViewTab('Ofertas', !_isMyMatchesView, isDark, () => setState(() => _isMyMatchesView = false))),
            Expanded(child: _buildViewTab('Mis Partidos', _isMyMatchesView, isDark, () => setState(() => _isMyMatchesView = true))),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTab(String label, bool isActive, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    context.read<MatchesBloc>().add(LoadMatchesEvent(
      sportId: selectedSportId,
      regionId: selectedRegionId,
      canchaId: selectedCanchaId,
      date: selectedDate,
    ));
  }

  void _openFiltersBottomSheet(BuildContext context) {
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
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtros Avanzados',
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedSportId = null;
                              selectedRegionId = null;
                              selectedCanchaId = null;
                              selectedDate = null;
                            });
                          },
                          child: const Text('Limpiar', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // DEPORTE
                    Text('Deporte', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildModalChip(
                          label: 'Todos',
                          isSelected: selectedSportId == null,
                          setModalState: setModalState,
                          onTap: () => setState(() => selectedSportId = null),
                        ),
                        ..._sports.map((s) => _buildModalChip(
                          label: s.name,
                          isSelected: selectedSportId == s.id,
                          setModalState: setModalState,
                          onTap: () => setState(() => selectedSportId = s.id),
                        )),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // FECHA
                    Text('Fecha', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null 
                                ? 'Seleccionar fecha' 
                                : DateFormat('EEEE, d MMMM', 'es_VE').format(selectedDate!),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                            const Spacer(),
                            if (selectedDate != null)
                              GestureDetector(
                                onTap: () {
                                  setModalState(() => selectedDate = null);
                                  setState(() => selectedDate = null);
                                },
                                child: const Icon(Icons.close, size: 18, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // CIUDAD / REGION
                    Text('Ciudad / Región', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedRegionId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Todas las regiones'),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas las regiones')),
                          ..._regions.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedRegionId = val;
                            selectedCanchaId = null; // Reset cancha when region changes
                          });
                          setState(() => selectedRegionId = val);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CANCHA
                    Text('Cancha', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedCanchaId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Todas las canchas'),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas las canchas')),
                          ..._canchas
                              .where((c) => selectedRegionId == null || c.regionId == selectedRegionId)
                              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (val) {
                          setModalState(() => selectedCanchaId = val);
                          setState(() => selectedCanchaId = val);
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(modalContext);
                        },
                        child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        color: isSelected ? AppColors.primary : (isDark ? Colors.transparent : Colors.grey.shade300),
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

  Widget _buildMatchCard(MatchEntity match, bool isDark, int? currentUserId) {
    final isOrganizer = currentUserId != null && match.idUsuarioOrg == currentUserId;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (match.idEquipoA != null) {
                context.push('/team-dashboard/${match.idEquipoA}');
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: match.logoEquipoA != null
                    ? Image.network(
                        match.logoEquipoA!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
                      )
                    : const Center(
                        child: Text(
                          '⚽',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (match.idEquipoA != null) {
                      context.push('/team-dashboard/${match.idEquipoA}');
                    }
                  },
                  child: Text(
                    match.nombreEquipoA ?? 'Partido #${match.id}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Text(
                  match.sportName ?? 'Deporte',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, _formatFullDate(match.fechaInicioEstimada), isDark),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.timer_outlined, _formatTimeRange(match.fechaInicioEstimada, match.fechaFinEstimada), isDark),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, match.nombreCancha ?? 'Ubicación no especificada', isDark),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.person_outline, 'Organizador: ${match.nombreCapitanA ?? 'Capi'}', isDark),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/match-details/${match.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isOrganizer ? 'Administrar Partido' : 'Aceptar Encuentro',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    // Ejemplo: Jueves 16 de abril del 2026
    final formatter = DateFormat("EEEE d 'de' MMMM 'del' y", 'es_VE');
    String formatted = formatter.format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final format = DateFormat('jm'); // Usa am/pm según locale
    return '${format.format(start).toLowerCase()} a ${format.format(end).toLowerCase()}';
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
