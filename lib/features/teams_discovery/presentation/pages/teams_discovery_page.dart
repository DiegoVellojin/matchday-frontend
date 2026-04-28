import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../bloc/teams_discovery_bloc.dart';
import '../bloc/teams_discovery_event.dart';
import '../bloc/teams_discovery_state.dart';
import '../widgets/team_discovery_card.dart';

class TeamsDiscoveryPage extends StatelessWidget {
  const TeamsDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el BLoC y cargamos los equipos inmediatamente
    return BlocProvider(
      create: (_) => sl<TeamsDiscoveryBloc>()..add(LoadTeamsEvent()),
      child: const _TeamsDiscoveryView(),
    );
  }
}

class _TeamsDiscoveryView extends StatefulWidget {
  const _TeamsDiscoveryView();

  @override
  State<_TeamsDiscoveryView> createState() => _TeamsDiscoveryViewState();
}

class _TeamsDiscoveryViewState extends State<_TeamsDiscoveryView> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Todos',
    'Fútbol',
    'Baloncesto',
    'Tenis',
    'Voleibol',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 20,
                        child: Icon(Icons.person_outline, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MatchDay',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      BlocBuilder<ThemeBloc, ThemeMode>(
                        builder: (context, themeMode) {
                          final isDarkTheme = themeMode == ThemeMode.dark;
                          return IconButton(
                            icon: Icon(
                              isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                              color: colorScheme.onSurface,
                            ),
                            onPressed: () =>
                                context.read<ThemeBloc>().add(ToggleThemeEvent()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none_outlined,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () => context.push('/notificaciones'),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            // Barra de Búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Icon(
                        Icons.search,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : Colors.grey.shade600,
                      ),
                    ),
                    hintText: 'Buscar equipos...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filtros horizontales
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filters.length + 1,
                itemBuilder: (context, index) {
                  if (index == _filters.length) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 16.0),
                      child: ActionChip(
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.border
                              : Colors.grey.shade300,
                        ),
                        label: Row(
                          children: [
                            Icon(
                              Icons.tune,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filtros',
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    );
                  }

                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      backgroundColor: colorScheme.surface,
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                  ? Colors.transparent
                                  : Colors.grey.shade300),
                      ),
                      label: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onSelected: (selected) =>
                          setState(() => _selectedFilterIndex = index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Grid de Equipos conectados al Backend (BLoC)
            Expanded(
              child: BlocConsumer<TeamsDiscoveryBloc, TeamsDiscoveryState>(
                listener: (context, state) {
                  if (state is TeamsDiscoveryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } else if (state is TeamJoinRequestSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TeamsDiscoveryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is TeamsDiscoveryLoaded) {
                    if (state.teams.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          final bloc = context.read<TeamsDiscoveryBloc>();
                          bloc.add(LoadTeamsEvent());
                          await bloc.stream.firstWhere((state) =>
                              state is TeamsDiscoveryLoaded ||
                              state is TeamsDiscoveryError);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'No hay equipos disponibles en este momento.',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<TeamsDiscoveryBloc>();
                        bloc.add(LoadTeamsEvent());
                        await bloc.stream.firstWhere((state) =>
                            state is TeamsDiscoveryLoaded ||
                            state is TeamsDiscoveryError);
                      },
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.teams.length,
                        itemBuilder: (context, index) {
                          final team = state.teams[index];
                          return TeamDiscoveryCard(
                            team: team,
                            onRequestJoin: () {
                              context.read<TeamsDiscoveryBloc>().add(
                                    RequestJoinTeamEvent(teamId: team.id),
                                  );
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
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
