import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/team_entity.dart';
import '../bloc/my_teams_bloc.dart';
import '../bloc/my_teams_event.dart';
import '../bloc/my_teams_state.dart';
import '../../../../core/widgets/matchday_filter_chips.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';

import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../payments/presentation/bloc/payments_event.dart';
import '../../../payments/presentation/bloc/payments_state.dart';
import '../../../payments/domain/entities/payment_entity.dart';

enum TeamFilter { all, player, organizer }

/// Pantalla que muestra y administra los equipos asociados al usuario.
class MyTeamsPage extends StatefulWidget {
  const MyTeamsPage({super.key});

  @override
  State<MyTeamsPage> createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> {
  TeamFilter _activeFilter = TeamFilter.all;
  List<TeamEntity> _cachedTeams = [];
  List<PaymentEntity> _cachedPayments = [];

  @override
  void initState() {
    super.initState();
    // Inicializar caché desde el estado actual del BLoC si ya existe
    final currentState = context.read<MyTeamsBloc>().state;
    if (currentState is MyTeamsLoaded) {
      _cachedTeams = currentState.teams;
    }
    
    final paymentsState = context.read<PaymentsBloc>().state;
    if (paymentsState is PaymentsLoaded) {
      _cachedPayments = paymentsState.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final int? currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Mis Equipos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  MatchDayFilterChips<TeamFilter>(
                    options: const [
                      FilterOption(label: 'Todos', value: TeamFilter.all),
                      FilterOption(label: 'Como Jugador', value: TeamFilter.player),
                      FilterOption(label: 'Como Organizador', value: TeamFilter.organizer),
                    ],
                    selectedValue: _activeFilter,
                    onSelected: (val) {
                      if (val != null) setState(() => _activeFilter = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // BARRA DE CARGA "FULL PERSISTENCIA"
                  BlocBuilder<MyTeamsBloc, MyTeamsState>(
                    builder: (context, state) {
                      return MatchDayLoadingBar(isLoading: state is MyTeamsLoading);
                    },
                  ),

                  Expanded(
                    child: BlocConsumer<MyTeamsBloc, MyTeamsState>(
                      listener: (context, state) {
                        if (state is MyTeamsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                          );
                        }
                        if (state is MyTeamsLoaded) {
                          setState(() => _cachedTeams = state.teams);
                        }
                      },
                      builder: (context, myTeamsState) {
                        return BlocConsumer<PaymentsBloc, PaymentsState>(
                          listener: (context, state) {
                            if (state is PaymentsLoaded) {
                              setState(() => _cachedPayments = state.payments);
                            }
                          },
                          builder: (context, paymentsState) {
                            final teamsToShow = myTeamsState is MyTeamsLoaded ? myTeamsState.teams : _cachedTeams;
                            final teams = _getFilteredTeams(teamsToShow, currentUserId);
                            
                            if (myTeamsState is MyTeamsLoading && teamsToShow.isEmpty) {
                              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                            }

                            if (teams.isEmpty && myTeamsState is! MyTeamsLoading) {
                              return _buildEmptyState();
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<MyTeamsBloc>().add(LoadMyTeamsEvent());
                                context.read<PaymentsBloc>().add(LoadMyPaymentsEvent());
                              },
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: teams.length,
                                separatorBuilder: (_, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final team = teams[index];
                                  final isCaptain = currentUserId != null && team.captainId == currentUserId;

                                  PaymentEntity? teamDebt;
                                  for (final p in _cachedPayments) {
                                    if (p.teamName == team.name && p.estatusPago == 'pendiente') {
                                      teamDebt = p;
                                      break;
                                    }
                                  }

                                  return _buildTeamCard(
                                    context,
                                    team,
                                    isCaptain,
                                    teamDebt != null,
                                    teamDebt?.monto ?? 0.0,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<TeamEntity> _getFilteredTeams(
    List<TeamEntity> teams,
    int? currentUserId,
  ) {
    if (currentUserId == null) return teams;
    switch (_activeFilter) {
      case TeamFilter.all:
        return teams;
      case TeamFilter.player:
        return teams.where((t) => t.captainId != currentUserId).toList();
      case TeamFilter.organizer:
        return teams.where((t) => t.captainId == currentUserId).toList();
    }
  }

  // Replaced by MatchDayFilterChips

  Widget _buildTeamCard(
    BuildContext context,
    TeamEntity team,
    bool isCaptain,
    bool hasDebt,
    double debtAmount,
  ) {
    final hasLogo =
        team.logo.isNotEmpty &&
        team.logo != '⚽' &&
        team.logo != '🏀' &&
        team.logo != '🎾';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.border : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: isDark ? AppColors.background : Colors.grey.shade100,
                  backgroundImage: hasLogo ? NetworkImage(team.logo) : null,
                  child: !hasLogo
                      ? Text(
                          team.logo.isNotEmpty ? team.logo : '⚽',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,

                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            team.sportName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isCaptain
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.orangeAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCaptain ? 'Organizador' : 'Jugador',
                            style: TextStyle(
                              color: isCaptain
                                  ? AppColors.primary
                                  : Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasDebt)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Deuda',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${debtAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (team.chatUrl != null && team.chatUrl!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(team.chatUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No se pudo abrir el enlace de contacto.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text(
                      'Contacto',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text(
                      'Sin Chat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/team-dashboard/${team.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),

                  child: Text(
                    isCaptain ? 'Gestionar' : 'Ver Equipo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No se encontraron equipos en esta categoría.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
