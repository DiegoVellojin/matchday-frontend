import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_status.dart';
import '../../../teams/domain/entities/sport_entity.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../../../catalogs/domain/entities/region_entity.dart';
import '../../../catalogs/domain/entities/cancha_entity.dart';
import '../../../catalogs/application/usecases/get_sports_usecase.dart'
    as cat_sports;
import '../../../catalogs/application/usecases/get_regions_usecase.dart';
import '../../../catalogs/application/usecases/get_canchas_usecase.dart';
import '../../../teams/application/usecases/get_my_teams_usecase.dart'
    as mt_usecase;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../catalogs/presentation/bloc/add_court/add_court_bloc.dart'
    as import_add_court_bloc;
import '../../../catalogs/presentation/pages/add_court_page.dart'
    as import_add_court_page;
import '../../../teams/presentation/bloc/teams_bloc.dart';
import '../../../teams/presentation/bloc/teams_state.dart';
import '../../../../features/main_hub/presentation/widgets/form_skeleton.dart';

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
  String selectedMoneda = 'USD';

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
      selectedMoneda = match.moneda;

      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      // Los controllers de tiempo se llenan en didChangeDependencies
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }

    // Optimizamos: Intentamos obtener datos de los Blocs existentes para evitar parpadeos
    final teamsState = context.read<TeamsBloc>().state;
    if (teamsState is TeamsLoaded) {
      _sports = teamsState.sports;
      // Filtramos solo los equipos donde soy capitán
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        _myTeams = teamsState.teams
            .where((t) => t.captainId == profileState.profile.id)
            .toList();
      } else {
        _myTeams = teamsState.teams;
      }

      if (widget.editMatch == null) {
        if (_sports.isNotEmpty) selectedSportId = _sports.first.id;
        if (_myTeams.isNotEmpty && selectedSportId != null) {
          final selectedSport = _sports
              .where((s) => s.id == selectedSportId)
              .firstOrNull;
          final filtered = _myTeams
              .where((t) => t.sportName == selectedSport?.name)
              .toList();
          if (filtered.isNotEmpty) selectedTeamId = filtered.first.id;
        }
      }

      _isLoadingSports = false;
      _isLoadingTeams = false;
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final List<Future<void>> futures = [];
    if (_sports.isEmpty) futures.add(_loadSports());
    if (_myTeams.isEmpty) futures.add(_loadMyTeams());
    futures.add(_loadRegions()); // Las regiones aún no se cachean globalmente

    await Future.wait(futures);

    // Si estamos editando, cargar canchas de la región si es posible
    if (widget.editMatch != null && selectedRegionId != null) {
      _loadCanchas(selectedRegionId!);
    }
  }

  Future<void> _loadSports() async {
    if (_sports.isNotEmpty) return;
    final useCase = sl<cat_sports.GetSportsUseCase>();
    final result = await useCase();
    result.fold((failure) => _showError('Error al cargar deportes'), (sports) {
      setState(() {
        _sports = sports;
        if (widget.editMatch == null && _sports.isNotEmpty) {
          selectedSportId = _sports.first.id;
        }
        _isLoadingSports = false;
      });
    });
  }

  Future<void> _loadMyTeams() async {
    final result = await sl<mt_usecase.GetMyTeamsUseCase>()();
    result.fold((failure) => _showError('Error al cargar tus equipos'), (
      teams,
    ) {
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

        if (widget.editMatch == null &&
            _myTeams.isNotEmpty &&
            selectedSportId != null) {
          final selectedSport = _sports
              .where((s) => s.id == selectedSportId)
              .firstOrNull;
          final filtered = _myTeams
              .where((t) => t.sportName == selectedSport?.name)
              .toList();
          if (filtered.isNotEmpty) selectedTeamId = filtered.first.id;
        }
        _isLoadingTeams = false;
      });
    });
  }

  Future<void> _loadRegions() async {
    final result = await sl<GetRegionsUseCase>()();
    result.fold((failure) => _showError('Error al cargar regiones'), (regions) {
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    });
  }

  Future<void> _loadCanchas(int regionId) async {
    setState(() {
      _isLoadingCanchas = true;
    });

    final result = await sl<GetCanchasUseCase>()(regionId: regionId);
    result.fold((failure) => _showError('Error al cargar canchas'), (canchas) {
      setState(() {
        _canchas = canchas;
        _isLoadingCanchas = false;
      });
    });
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              const SnackBar(
                content: Text('Partido actualizado con éxito'),
                backgroundColor: AppColors.primary,
              ),
            );
            context.pop();
          }
        },
        child: (_isLoadingSports || _isLoadingTeams || _isLoadingRegions)
            ? const FormSkeleton()
            : Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 120,
                        pinned: true,
                        elevation: 0,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            widget.editMatch != null
                                ? 'Editar Partido'
                                : 'Crear Partido',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),
                          centerTitle: false,
                          titlePadding: const EdgeInsets.only(
                            left: 56,
                            bottom: 16,
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? Colors.white : Colors.black,
                            size: 20,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('DEPORTE Y EQUIPO', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumLabel('Deporte'),
                              _buildPremiumSportSelector(isDark),
                              const SizedBox(height: 24),

                              _buildPremiumLabel('Tu Equipo'),
                              _buildPremiumTeamSelector(isDark),
                              const SizedBox(height: 32),

                              _buildSectionTitle('PROGRAMACIÓN', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumLabel('Fecha del Encuentro'),
                              _buildPremiumTextField(
                                controller: _dateController,
                                hint: 'Selecciona la fecha',
                                icon: Icons.calendar_today_rounded,
                                isDark: isDark,
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 90),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      selectedDate = date;
                                      _dateController.text = DateFormat(
                                        'EEEE, d MMMM',
                                        'es_VE',
                                      ).format(date);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPremiumLabel('Hora Inicio'),
                                        _buildPremiumTextField(
                                          controller: _startController,
                                          hint: '00:00',
                                          icon: Icons.access_time_rounded,
                                          isDark: isDark,
                                          readOnly: true,
                                          onTap: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: startTime,
                                            );
                                            if (time != null) {
                                              setState(() {
                                                startTime = time;
                                                _startController.text = time
                                                    .format(context);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPremiumLabel('Hora Fin'),
                                        _buildPremiumTextField(
                                          controller: _endController,
                                          hint: '00:00',
                                          icon:
                                              Icons.access_time_filled_rounded,
                                          isDark: isDark,
                                          readOnly: true,
                                          onTap: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: endTime,
                                            );
                                            if (time != null) {
                                              setState(() {
                                                endTime = time;
                                                _endController.text = time
                                                    .format(context);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              _buildSectionTitle('UBICACIÓN', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumLabel('Ciudad / Región'),
                              _buildPremiumRegionSelector(isDark),
                              const SizedBox(height: 24),

                              _buildPremiumLabel('Cancha'),
                              _buildPremiumCanchaSelector(isDark),

                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => _navigateToAddCourt(),
                                icon: const Icon(
                                  Icons.add_location_alt_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                label: const Text(
                                  '¿Cancha no listada? Añádela aquí',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomActions(isDark),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPremiumLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildPremiumSportSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedSportId,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: _sports
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedSportId = val;
              final selectedSport = _sports
                  .where((s) => s.id == val)
                  .firstOrNull;
              final filteredTeams = _myTeams
                  .where((t) => t.sportName == selectedSport?.name)
                  .toList();
              selectedTeamId = filteredTeams.isNotEmpty
                  ? filteredTeams.first.id
                  : null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPremiumTeamSelector(bool isDark) {
    final selectedSport = _sports
        .where((s) => s.id == selectedSportId)
        .firstOrNull;
    final filteredTeams = _myTeams
        .where((t) => t.sportName == selectedSport?.name)
        .toList();

    if (filteredTeams.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              'No eres capitán de ningún equipo de ${selectedSport?.name ?? "este deporte"}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/crear-equipo'),
              child: const Text(
                'Crear Equipo ahora',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: filteredTeams.any((t) => t.id == selectedTeamId)
              ? selectedTeamId
              : (filteredTeams.isNotEmpty ? filteredTeams.first.id : null),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: filteredTeams
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedTeamId = val),
        ),
      ),
    );
  }

  Widget _buildPremiumRegionSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedRegionId,
          hint: Text(
            'Selecciona una ciudad',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: _regions
              .map(
                (r) => DropdownMenuItem(
                  value: r.id,
                  child: Text(
                    r.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => selectedRegionId = val);
            if (val != null) _loadCanchas(val);
          },
        ),
      ),
    );
  }

  Widget _buildPremiumCanchaSelector(bool isDark) {
    if (selectedRegionId == null)
      return Text(
        'Primero selecciona una ciudad',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      );
    if (_isLoadingCanchas)
      return const LinearProgressIndicator(color: AppColors.primary);
    if (_canchas.isEmpty)
      return Text(
        'No hay canchas registradas en esta ciudad.',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedCanchaId,
          hint: Text(
            'Selecciona una cancha',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: _canchas
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedCanchaId = val),
        ),
      ),
    );
  }

  Future<void> _navigateToAddCourt() async {
    if (selectedRegionId == null) {
      _showError('Por favor selecciona una ciudad primero.');
      return;
    }
    final newCancha = await Navigator.push<CanchaEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => sl<import_add_court_bloc.AddCourtBloc>(),
          child: import_add_court_page.AddCourtPage(
            regionId: selectedRegionId!,
          ),
        ),
      ),
    );
    if (newCancha != null) {
      await _loadCanchas(selectedRegionId!);
      setState(() => selectedCanchaId = newCancha.id);
    }
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: AnimatedBouncingButton(
        onTap: _canSubmit()
            ? () {
                if (widget.editMatch != null) {
                  _submit();
                } else {
                  context.read<MatchesBloc>().add(
                    SearchSimilarMatchesEvent(
                      sportId: selectedSportId!,
                      date: selectedDate,
                    ),
                  );
                }
              }
            : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _canSubmit()
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _canSubmit()
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: BlocBuilder<MatchesBloc, MatchesState>(
              builder: (context, state) {
                if (state is MatchesLoading) {
                  return const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  );
                }
                return Text(
                  widget.editMatch != null
                      ? 'GUARDAR CAMBIOS'
                      : 'BUSCAR O CREAR PARTIDO',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return selectedSportId != null &&
        selectedTeamId != null &&
        selectedCanchaId != null;
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

  void _showSimilarMatchesModal(List<MatchEntity> similar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Partidos Similares',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hemos encontrado encuentros que podrían interesarte. ¡Únete a uno y juega ya!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: similar.length,
                  itemBuilder: (context, index) =>
                      _buildSimilarMatchCard(context, similar[index], isDark),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBouncingButton(
                onTap: () {
                  Navigator.pop(context);
                  _submit();
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'IGNORAR Y CREAR EL MÍO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarMatchCard(
    BuildContext context,
    MatchEntity match,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partido #${match.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM • HH:mm',
                        'es_VE',
                      ).format(match.fechaInicioEstimada),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DISPONIBLE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBouncingButton(
            onTap: () {
              Navigator.pop(context);
              context.push('/match-details/${match.id}');
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'VER DETALLES',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
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
      _showError(
        'No se pudo determinar el usuario. Por favor intenta de nuevo.',
      );
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
      moneda: selectedMoneda,
      status: MatchStatus.fromString(widget.editMatch?.estatus ?? 'publicada'),
      idEquipoA: selectedTeamId,
      cuposTotales: widget.editMatch?.cuposTotales ?? 22,
      jugadoresInscritos: widget.editMatch?.jugadoresInscritos ?? 0,
      cuotaPorJugador: widget.editMatch?.cuotaPorJugador ?? 0.0,
    );

    if (widget.editMatch != null) {
      context.read<MatchesBloc>().add(UpdateMatchEvent(match));
    } else {
      context.read<MatchesBloc>().add(CreateMatchEvent(match));
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de creación enviada'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
