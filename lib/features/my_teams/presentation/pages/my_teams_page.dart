import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../teams_discovery/presentation/pages/team_dashboard_page.dart';
import '../../domain/entities/my_team_entity.dart';
import '../bloc/my_teams_bloc.dart';
import '../bloc/my_teams_event.dart';
import '../bloc/my_teams_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MyTeamsBloc>(
          create: (context) => sl<MyTeamsBloc>()..add(LoadMyTeamsEvent()),
        ),
        BlocProvider<PaymentsBloc>(
          create: (context) => sl<PaymentsBloc>()..add(LoadMyPaymentsEvent()),
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          final int? currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;

          return BlocBuilder<PaymentsBloc, PaymentsState>(
            builder: (context, paymentsState) {
              final paymentsList = paymentsState is PaymentsLoaded ? paymentsState.payments : [];

              return BlocConsumer<MyTeamsBloc, MyTeamsState>(
                listener: (context, state) {
                  if (state is MyTeamsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                    );
                  }
                },
                builder: (context, myTeamsState) {
                  if (myTeamsState is MyTeamsLoading || paymentsState is PaymentsLoading) {
                    return const Scaffold(
                      backgroundColor: AppColors.background,
                      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  if (myTeamsState is MyTeamsLoaded) {
                    final teams = _getFilteredTeams(myTeamsState.teams, currentUserId);
                    
                    // Calcular pagos pendientes
                    final pendingPaymentsCount = paymentsList.where((p) => p.estatusPago == 'pendiente').length;


                    return Scaffold(
                      backgroundColor: AppColors.background,
                      body: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              const Text(
                                'Mis Equipos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${myTeamsState.teams.length} equipos • $pendingPaymentsCount pagos pendientes',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              _buildMicroFilters(),
                              const SizedBox(height: 20),
                              Expanded(
                                child: teams.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        itemCount: teams.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final team = teams[index];
                                          final isCaptain = currentUserId != null && team.captainId == currentUserId;
                                          
                                          // Verificar si el equipo actual tiene deudas
                                          final teamDebt = paymentsList.firstWhere(
                                            (p) => p.teamName == team.name && p.estatusPago == 'pendiente',
                                            orElse: () => const PaymentEntity(
                                              idPartida: 0,
                                              teamName: '',
                                              concepto: '',
                                              monto: 0,
                                              isPaid: false,
                                              estatusPago: '',
                                            ),
                                          );
                                          
                                          final hasDebt = teamDebt.idPartida != 0;


                                          return _buildTeamCard(context, team, isCaptain, hasDebt, teamDebt.monto);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const Scaffold(
                    backgroundColor: AppColors.background,
                    body: SizedBox.shrink(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<MyTeamEntity> _getFilteredTeams(List<MyTeamEntity> teams, int? currentUserId) {
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

  Widget _buildMicroFilters() {
    return Row(
      children: [
        _buildFilterButton('Todos', TeamFilter.all),
        const SizedBox(width: 8),
        _buildFilterButton('Como Jugador', TeamFilter.player),
        const SizedBox(width: 8),
        _buildFilterButton('Como Organizador', TeamFilter.organizer),
      ],
    );
  }

  Widget _buildFilterButton(String text, TeamFilter filter) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
            : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.background : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, MyTeamEntity team, bool isCaptain, bool hasDebt, double debtAmount) {
    final hasLogo = team.logo.isNotEmpty && team.logo != '⚽' && team.logo != '🏀' && team.logo != '🎾';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.background,
                  backgroundImage: hasLogo ? NetworkImage(team.logo) : null,
                  child: !hasLogo
                      ? Text(team.logo.isNotEmpty ? team.logo : '⚽', style: const TextStyle(fontSize: 24))
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
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          team.sportName,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCaptain 
                              ? AppColors.primary.withValues(alpha: 0.15) 
                              : Colors.orangeAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCaptain ? 'Organizador' : 'Jugador',
                            style: TextStyle(
                              color: isCaptain ? AppColors.primary : Colors.orangeAccent,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Deuda',
                        style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${debtAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (team.urlChatEquipo != null && team.urlChatEquipo!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(team.urlChatEquipo!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No se pudo abrir el enlace de contacto.')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Contacto', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Sin Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TeamDashboardPage(teamId: team.id)),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<MyTeamsBloc>().add(LoadMyTeamsEvent());
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      child: Text('No se encontraron equipos en esta categoría.', style: TextStyle(color: AppColors.textMuted)),
    );
  }
}
