import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_status.dart';
import '../../../../core/widgets/matchday_filter_chips.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';
import '../../../../core/widgets/matchday_search_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teams/domain/entities/sport_entity.dart';
import '../../../catalogs/application/usecases/get_sports_usecase.dart'
    as cat_usecase;
import '../../../catalogs/domain/entities/region_entity.dart';
import '../../../catalogs/domain/entities/cancha_entity.dart';
import '../../../catalogs/application/usecases/get_regions_usecase.dart';
import '../../../catalogs/application/usecases/get_canchas_usecase.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../utils/match_action_handler.dart';
import '../widgets/matches_skeleton.dart';
import '../../../../core/widgets/matchday_marquee.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int? selectedSportId;
  int? selectedRegionId;
  int? selectedCanchaId;
  DateTime? selectedDate;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? selectedStatus;
  List<SportEntity> _sports = [];
  List<RegionEntity> _regions = [];
  List<CanchaEntity> _canchas = [];
  List<MatchEntity> _cachedMatches = [];

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
    super.build(context);
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRÓXIMOS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'Encuentros',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MatchDaySearchBar(
              controller: _searchController,
              hintText: 'Buscar partidos...',
            ),
          ),
          const SizedBox(height: 16),
          _buildPremiumViewSelector(isDark),
          const SizedBox(height: 16),

          if (!_isLoadingCatalogs)
            MatchDayFilterChips<int?>(
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

          BlocBuilder<MatchesBloc, MatchesState>(
            builder: (context, state) => MatchDayLoadingBar(
              isLoading: state is MatchesLoading || _isLoadingCatalogs,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BlocConsumer<MatchesBloc, MatchesState>(
                listener: (context, state) {
                  if (state is MatchesLoaded) {
                    setState(() => _cachedMatches = state.matches);
                  }
                },
                builder: (context, state) {
                  final matchesToShow = state is MatchesLoaded
                      ? state.matches
                      : _cachedMatches;

                  if (state is MatchesLoading && matchesToShow.isEmpty) {
                    return const MatchesSkeleton();
                  }

                  final profileState = context.read<ProfileBloc>().state;
                  int? currentUserId = profileState is ProfileLoaded
                      ? profileState.profile.id
                      : null;

                  final filteredMatches = matchesToShow.where((m) {
                    if (_isMyMatchesView) return true;
                    if (m.idUsuarioOrg == currentUserId) return false;
                    if (m.idEquipoB != null) return false;
                    return _searchQuery.isEmpty ||
                        m.sportName?.toLowerCase().contains(_searchQuery) ==
                            true ||
                        m.nombreEquipoA?.toLowerCase().contains(_searchQuery) ==
                            true;
                  }).toList();

                  // Avoid Hero tag duplication by ensuring uniqueness
                  final uniqueMatches = <int, MatchEntity>{};
                  for (var m in filteredMatches) {
                    uniqueMatches[m.id] = m;
                  }
                  final finalMatches = uniqueMatches.values.toList();

                  if (finalMatches.isEmpty && state is! MatchesLoading) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<MatchesBloc>().add(
                      LoadMatchesEvent(
                        sportId: selectedSportId,
                        status: selectedStatus,
                        regionId: selectedRegionId,
                        canchaId: selectedCanchaId,
                        date: selectedDate,
                        mine: _isMyMatchesView,
                      ),
                    ),
                    color: AppColors.primary,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 100, top: 12),
                      itemCount: finalMatches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildPremiumMatchCard(
                                finalMatches[index],
                                isDark,
                                currentUserId,
                                _isMyMatchesView,
                              )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                curve: Curves.easeOutQuad,
                              ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'matches_fab',
        onPressed: () => context.push('/crear-partido'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, weight: 900),
        label: const Text(
          'ORGANIZAR',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildPremiumViewSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            _buildSelectorTab('DESCUBRIR', !_isMyMatchesView, isDark, () {
              setState(() => _isMyMatchesView = false);
              _applyFilters();
            }),
            const SizedBox(width: 6),
            _buildSelectorTab('MIS PARTIDOS', _isMyMatchesView, isDark, () {
              setState(() => _isMyMatchesView = true);
              _applyFilters();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTab(
    String label,
    bool isActive,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.primary : Colors.black)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (isDark ? AppColors.primary : Colors.black).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPremiumMatchCard(
    MatchEntity match,
    bool isDark,
    int? currentUserId,
    bool isMyMatch,
  ) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dateStr = _formatFullDate(match.fechaInicioEstimada);
    final timeStr = _formatTimeRange(
      match.fechaInicioEstimada,
      match.fechaFinEstimada,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTeamLogo(match),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.nombreEquipoA?.toUpperCase() ?? 'PARTIDO #${match.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                match.sportName?.toUpperCase() ?? 'DEPORTE',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(match.estatus),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Cancha con Marquee y más visibilidad
                      Row(
                        children: [
                          Icon(Icons.stadium_rounded, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: MatchDayMarquee(
                              text: match.nombreCancha ?? 'Sin sede definida',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: _buildIconInfo(Icons.calendar_today_rounded, dateStr, isDark)),
                      const SizedBox(width: 8),
                      Flexible(child: _buildIconInfo(Icons.access_time_rounded, timeStr, isDark)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(match, currentUserId, isMyMatch),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(MatchEntity match) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Hero(
        tag: 'team_logo_${match.idEquipoA}_match_${match.id}',
        child: ClipOval(
          child:
              (match.logoEquipoA != null &&
                  match.logoEquipoA!.isNotEmpty &&
                  match.logoEquipoA != 'null')
              ? Image.network(match.logoEquipoA!, fit: BoxFit.cover)
              : const Center(child: Text('⚽', style: TextStyle(fontSize: 22))),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final st = MatchStatus.fromString(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: st.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        st.label.toUpperCase(),
        style: TextStyle(
          color: st.color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    MatchEntity match,
    int? currentUserId,
    bool isMyMatch,
  ) {
    final action = MatchActionHandler.resolve(
      context: context,
      match: match,
      currentUserId: currentUserId,
      isMyMatch: isMyMatch,
    );
    return ElevatedButton(
      onPressed: action.onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(100, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        action.label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isMyMatchesView
                ? Icons.sports_soccer_rounded
                : Icons.search_off_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Text(
            _isMyMatchesView ? 'Aún no tienes partidos' : 'No hay ofertas',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            _isMyMatchesView
                ? '¡Organiza tu primer encuentro!'
                : 'Prueba cambiando los filtros.',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) =>
      DateFormat("d 'de' MMM", 'es_VE').format(date.toLocal());
  String _formatTimeRange(DateTime start, DateTime end) =>
      DateFormat('jm', 'es_VE').format(start.toLocal()).toLowerCase();

  void _applyFilters() {
    context.read<MatchesBloc>().add(
      LoadMatchesEvent(
        sportId: selectedSportId,
        status: selectedStatus,
        regionId: selectedRegionId,
        canchaId: selectedCanchaId,
        date: selectedDate,
        mine: _isMyMatchesView,
      ),
    );
  }

  void _openFiltersBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros Avanzados',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedSportId = null;
                            selectedStatus = null;
                            selectedRegionId = null;
                            selectedCanchaId = null;
                            selectedDate = null;
                          });
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildFilterSection('Deporte', [
                    _buildModalChip(
                      label: 'Todos',
                      isSelected: selectedSportId == null,
                      setModalState: setModalState,
                      onTap: () => setState(() => selectedSportId = null),
                    ),
                    ..._sports.map(
                      (s) => _buildModalChip(
                        label: s.name,
                        isSelected: selectedSportId == s.id,
                        setModalState: setModalState,
                        onTap: () => setState(() => selectedSportId = s.id),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildFilterSection('Estado', [
                    _buildModalChip(
                      label: 'Todos',
                      isSelected: selectedStatus == null,
                      setModalState: setModalState,
                      onTap: () => setState(() => selectedStatus = null),
                    ),
                    ...[
                      const PublishedStatus(),
                      const NegotiatingStatus(),
                      const PendingPaymentStatus(),
                      const ConfirmedStatus(),
                      const CompletedStatus(),
                    ].map(
                      (st) => _buildModalChip(
                        label: st.label,
                        isSelected: selectedStatus == st.name,
                        setModalState: setModalState,
                        onTap: () => setState(() => selectedStatus = st.name),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  const Text(
                    'FECHA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate == null
                                ? 'Seleccionar fecha'
                                : DateFormat(
                                    'EEEE, d MMMM',
                                    'es_VE',
                                  ).format(selectedDate!),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildFilterSection('Región', [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedRegionId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Todas las regiones'),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas las regiones'),
                          ),
                          ..._regions.map(
                            (r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedRegionId = val;
                            selectedCanchaId = null;
                          });
                          setState(() => selectedRegionId = val);
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildFilterSection('Cancha', [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedCanchaId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Todas las canchas'),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas las canchas'),
                          ),
                          ..._canchas
                              .where(
                                (c) =>
                                    selectedRegionId == null ||
                                    c.regionId == selectedRegionId,
                              )
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                        ],
                        onChanged: (val) {
                          setModalState(() => selectedCanchaId = val);
                          setState(() => selectedCanchaId = val);
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'APLICAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
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
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1)),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      onSelected: (_) => setModalState(onTap),
    );
  }
}
