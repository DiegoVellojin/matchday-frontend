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

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  int? selectedSportId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_VE', null);
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
                MatchDayFilterChips<int?>(
                  options: const [
                    FilterOption(label: 'Todos', value: null),
                    FilterOption(label: 'Fútbol', value: 1),
                    FilterOption(label: 'Baloncesto', value: 2),
                  ],
                  selectedValue: selectedSportId,
                  onSelected: (val) {
                    setState(() => selectedSportId = val);
                    context.read<MatchesBloc>().add(LoadMatchesEvent(sportId: val));
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
      final filteredMatches = state.matches.where((m) {
        final matchesSearch = _searchQuery.isEmpty ||
            m.id.toString().contains(_searchQuery) ||
            _getSportName(m.idDeporte).toLowerCase().contains(_searchQuery);
        return matchesSearch;
      }).toList();

      if (filteredMatches.isEmpty) {
        return const Center(child: Text('No hay partidos que coincidan.', style: TextStyle(color: Color(0xFF9CA3AF))));
      }
      return ListView.separated(
        itemCount: filteredMatches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final match = filteredMatches[index];
          return _buildMatchCard(match, isDark);
        },
      );
    }
    return const SizedBox();
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
                  Text('Filtros Avanzados',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
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
                      _buildModalChip(
                        label: 'Fútbol',
                        isSelected: selectedSportId == 1,
                        setModalState: setModalState,
                        onTap: () => setState(() => selectedSportId = 1),
                      ),
                      _buildModalChip(
                        label: 'Baloncesto',
                        isSelected: selectedSportId == 2,
                        setModalState: setModalState,
                        onTap: () => setState(() => selectedSportId = 2),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        context.read<MatchesBloc>().add(LoadMatchesEvent(sportId: selectedSportId));
                        Navigator.pop(modalContext);
                      },
                      child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildMatchCard(MatchEntity match, bool isDark) {
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
          Container(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.nombreEquipoA ?? 'Partido #${match.id}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getSportName(match.idDeporte),
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
                    child: const Text(
                      'Aceptar Encuentro',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  String _getSportName(int id) {
    if (id == 1) return 'Fútbol';
    if (id == 2) return 'Baloncesto';
    return 'Deporte';
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
