import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../../teams/domain/entities/sport_entity.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../../../catalogs/domain/entities/region_entity.dart';
import '../../../catalogs/domain/entities/cancha_entity.dart';
import '../../../catalogs/application/usecases/get_sports_usecase.dart' as cat_sports;
import '../../../catalogs/application/usecases/get_regions_usecase.dart';
import '../../../catalogs/application/usecases/get_canchas_usecase.dart';
import '../../../teams/application/usecases/get_my_teams_usecase.dart' as mt_usecase;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../catalogs/presentation/bloc/add_court/add_court_bloc.dart' as import_add_court_bloc;
import '../../../catalogs/presentation/pages/add_court_page.dart' as import_add_court_page;
class CreateMatchPage extends StatefulWidget {
  final MatchEntity? editMatch;
  const CreateMatchPage({super.key, this.editMatch});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  // Datos de formulario
  int? selectedSportId;
  int? selectedTeamId;
  int? selectedRegionId;
  int? selectedCanchaId;
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

  // Controladores
  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  // Estados de carga y listas
  bool _isLoadingSports = true;
  bool _isLoadingTeams = true;
  bool _isLoadingRegions = true;
  bool _isLoadingCanchas = false;

  List<SportEntity> _sports = [];
  List<TeamEntity> _myTeams = [];
  List<RegionEntity> _regions = [];
  List<CanchaEntity> _canchas = [];

  @override
  void initState() {
    super.initState();
    if (widget.editMatch != null) {
      final match = widget.editMatch!;
      selectedSportId = match.idDeporte;
      selectedTeamId = match.idEquipoA;
      selectedCanchaId = match.idCancha;
      selectedDate = match.fechaInicioEstimada;
      startTime = TimeOfDay.fromDateTime(match.fechaInicioEstimada);
      endTime = TimeOfDay.fromDateTime(match.fechaFinEstimada);
      
      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      // Los controllers de tiempo se llenan en didChangeDependencies
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSports(),
      _loadMyTeams(),
      _loadRegions(),
    ]);
    
    // Si estamos editando, cargar canchas de la región si es posible
    if (widget.editMatch != null && selectedRegionId != null) {
      _loadCanchas(selectedRegionId!);
    }
  }

  Future<void> _loadSports() async {
    final result = await sl<cat_sports.GetSportsUseCase>()();
    result.fold(
      (failure) => _showError('Error al cargar deportes'),
      (sports) {
        setState(() {
          _sports = sports;
          if (widget.editMatch == null && _sports.isNotEmpty) {
            selectedSportId = _sports.first.id;
          }
          _isLoadingSports = false;
        });
      },
    );
  }

  Future<void> _loadMyTeams() async {
    final result = await sl<mt_usecase.GetMyTeamsUseCase>()();
    result.fold(
      (failure) => _showError('Error al cargar tus equipos'),
      (teams) {
        final profileState = context.read<ProfileBloc>().state;
        final authState = context.read<AuthBloc>().state;
        
        int? userId;
        if (profileState is ProfileLoaded) {
          userId = profileState.profile.id;
        } else if (authState is AuthAuthenticated) {
          userId = int.tryParse(authState.user.id);
        }

        setState(() {
          if (userId != null) {
            _myTeams = teams.where((t) => t.captainId == userId).toList();
          } else {
            _myTeams = teams;
          }
          
          if (widget.editMatch == null && _myTeams.isNotEmpty && selectedSportId != null) {
            final selectedSport = _sports.where((s) => s.id == selectedSportId).firstOrNull;
            final filtered = _myTeams.where((t) => t.sportName == selectedSport?.name).toList();
            if (filtered.isNotEmpty) selectedTeamId = filtered.first.id;
          }
          _isLoadingTeams = false;
        });
      },
    );
  }

  Future<void> _loadRegions() async {
    final result = await sl<GetRegionsUseCase>()();
    result.fold(
      (failure) => _showError('Error al cargar regiones'),
      (regions) {
        setState(() {
          _regions = regions;
          _isLoadingRegions = false;
        });
      },
    );
  }

  Future<void> _loadCanchas(int regionId) async {
    setState(() {
      _isLoadingCanchas = true;
    });
    
    final result = await sl<GetCanchasUseCase>()(regionId: regionId);
    result.fold(
      (failure) => _showError('Error al cargar canchas'),
      (canchas) {
        setState(() {
          _canchas = canchas;
          _isLoadingCanchas = false;
        });
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startController.text.isEmpty) {
      _startController.text = startTime.format(context);
    }
    if (_endController.text.isEmpty) {
      _endController.text = endTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Crear Partido', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is SimilarMatchesFound) {
            if (state.similarMatches.isEmpty) {
              _submit();
            } else {
              _showSimilarMatchesModal(state.similarMatches);
            }
          } else if (state is MatchUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Partido actualizado con éxito'), backgroundColor: AppColors.primary),
            );
            context.pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica', isDark),
              const SizedBox(height: 16),
              
              // Selector de Deporte
              _buildLabel('Deporte'),
              _isLoadingSports 
                ? const LinearProgressIndicator(color: AppColors.primary)
                : _buildDropdown<int>(
                    value: selectedSportId,
                    items: _sports.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSportId = val;
                        // Resetear equipo seleccionado al cambiar de deporte
                        final selectedSport = _sports.where((s) => s.id == val).firstOrNull;
                        final filteredTeams = _myTeams.where((t) => t.sportName == selectedSport?.name).toList();
                        if (filteredTeams.isNotEmpty) {
                          selectedTeamId = filteredTeams.first.id;
                        } else {
                          selectedTeamId = null;
                        }
                      });
                    },
                    isDark: isDark,
                  ),
              
              const SizedBox(height: 20),
              
              // Selector de Mi Equipo
              _buildLabel('Tu Equipo Organizador'),
              _isLoadingTeams
                ? const LinearProgressIndicator(color: AppColors.primary)
                : () {
                    final selectedSport = _sports.where((s) => s.id == selectedSportId).firstOrNull;
                    final filteredTeams = _myTeams.where((t) => t.sportName == selectedSport?.name).toList();
                    
                    if (filteredTeams.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              selectedSport != null 
                                ? 'No organizas ningún equipo de ${selectedSport.name} todavía.'
                                : 'No organizas ningún equipo todavía.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context.push('/crear-equipo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text('Crear un Equipo ahora'),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildDropdown<int>(
                      value: filteredTeams.any((t) => t.id == selectedTeamId) ? selectedTeamId : (filteredTeams.isNotEmpty ? filteredTeams.first.id : null),
                      items: filteredTeams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                      onChanged: (val) => setState(() => selectedTeamId = val),
                      isDark: isDark,
                    );
                  }(),

              const SizedBox(height: 32),
              _buildSectionTitle('Fecha y Hora', isDark),
              const SizedBox(height: 16),

              _buildLabel('Fecha del Partido'),
              _buildTextField(Icons.calendar_today, 'Selecciona la fecha', isDark, controller: _dateController, onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  });
                }
              }),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hora Inicio'),
                        _buildTextField(Icons.access_time, '00:00', isDark, controller: _startController, onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: startTime);
                          if (time != null) {
                            setState(() {
                              startTime = time;
                              _startController.text = time.format(context);
                            });
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hora Fin'),
                        _buildTextField(Icons.access_time, '00:00', isDark, controller: _endController, onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: endTime);
                          if (time != null) {
                            setState(() {
                              endTime = time;
                              _endController.text = time.format(context);
                            });
                          }
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Ubicación / Cancha', isDark),
              const SizedBox(height: 16),

              // Selector de Ciudad/Región
              _buildLabel('Ciudad / Región'),
              _isLoadingRegions
                ? const LinearProgressIndicator(color: AppColors.primary)
                : _buildDropdown<int>(
                    value: selectedRegionId,
                    hint: 'Selecciona una ciudad',
                    items: _regions.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                    onChanged: (val) {
                      setState(() => selectedRegionId = val);
                      if (val != null) _loadCanchas(val);
                    },
                    isDark: isDark,
                  ),

              const SizedBox(height: 20),

              // Selector de Cancha
              _buildLabel('Seleccionar Cancha'),
              _isLoadingCanchas
                ? const LinearProgressIndicator(color: AppColors.primary)
                : selectedRegionId == null
                  ? const Text('Primero selecciona una ciudad', style: TextStyle(color: Colors.grey, fontSize: 12))
                  : _canchas.isEmpty
                    ? const Text('No hay canchas registradas en esta ciudad.', style: TextStyle(color: Colors.grey, fontSize: 12))
                    : _buildDropdown<int>(
                        value: selectedCanchaId,
                        hint: 'Selecciona una cancha',
                        items: _canchas.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => selectedCanchaId = val),
                        isDark: isDark,
                      ),
              
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  if (selectedRegionId == null) {
                    _showError('Por favor selecciona una ciudad primero.');
                    return;
                  }
                  final newCancha = await Navigator.push<CanchaEntity>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => sl<import_add_court_bloc.AddCourtBloc>(),
                        child: import_add_court_page.AddCourtPage(regionId: selectedRegionId!),
                      ),
                    ),
                  );
                  if (newCancha != null) {
                    await _loadCanchas(selectedRegionId!);
                    setState(() {
                      selectedCanchaId = newCancha.id;
                    });
                  }
                },
                icon: const Icon(Icons.add_location_alt, color: AppColors.primary, size: 18),
                label: const Text('¿No encuentras la cancha? Añádela aquí', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: ElevatedButton(
          onPressed: _canSubmit() ? () {
            if (widget.editMatch != null) {
              _submit();
            } else {
              context.read<MatchesBloc>().add(SearchSimilarMatchesEvent(
                sportId: selectedSportId!,
                date: selectedDate,
              ));
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          ),
          child: BlocBuilder<MatchesBloc, MatchesState>(
            builder: (context, state) {
              if (state is MatchesLoading) {
                return const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                );
              }
              return const Text('Buscar o Crear Partido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
            },
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return selectedSportId != null && selectedTeamId != null && selectedCanchaId != null;
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9CA3AF) : Colors.black54, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
    String? hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null ? Text(hint, style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])) : null,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surface,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, bool isDark, {TextEditingController? controller, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? const Color(0xFF4A4A4A) : Colors.grey[400]),
          prefixIcon: Icon(icon, color: isDark ? const Color(0xFF9CA3AF) : Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }

  void _showSimilarMatchesModal(List<MatchEntity> similar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Partidos Similares Encontrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text('Tal vez quieras unirte a uno de estos en lugar de crear uno nuevo.', textAlign: TextAlign.center, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.grey : Colors.black54)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: similar.length,
                  itemBuilder: (context, index) => _buildSimilarMatchCard(context, similar[index], theme.brightness == Brightness.dark),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitCreate();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Ignorar y crear mi partido', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarMatchCard(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Text('⚽')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Partido #${match.id}', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  Text('Fútbol', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/match-details/${match.id}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Unirme a este partido'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    final profileState = context.read<ProfileBloc>().state;
    final authState = context.read<AuthBloc>().state;
    
    int? userId;
    if (profileState is ProfileLoaded) {
      userId = profileState.profile.id;
    } else if (authState is AuthAuthenticated) {
      userId = int.tryParse(authState.user.id);
    }
    
    if (userId == null) {
      _showError('No se pudo determinar el usuario. Por favor intenta de nuevo.');
      return;
    }
    
    final match = MatchEntity(
      id: widget.editMatch?.id ?? 0,
      idUsuarioOrg: userId,
      idDeporte: selectedSportId!,
      idCancha: selectedCanchaId!,
      fechaInicioEstimada: startDateTime,
      fechaFinEstimada: endDateTime,
      costoTotal: widget.editMatch?.costoTotal ?? 50.0,
      estatus: widget.editMatch?.estatus ?? 'publicada',
      idEquipoA: selectedTeamId,
    );

    if (widget.editMatch != null) {
      context.read<MatchesBloc>().add(UpdateMatchEvent(match));
    } else {
      context.read<MatchesBloc>().add(CreateMatchEvent(match));
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud de creación enviada'), backgroundColor: AppColors.primary),
      );
    }
  }
}
