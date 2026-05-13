import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/team_entity.dart';
import '../bloc/my_teams_bloc.dart';
import '../bloc/my_teams_event.dart';
import '../bloc/my_teams_state.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';
import '../../../../core/widgets/matchday_search_bar.dart';
import '../widgets/my_teams_skeleton.dart';

import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../payments/presentation/bloc/payments_event.dart';
import '../../../payments/presentation/bloc/payments_state.dart';
import '../../../payments/domain/entities/payment_entity.dart';

enum TeamFilter { all, player, capitan }

class MyTeamsPage extends StatefulWidget {
  const MyTeamsPage({super.key});

  @override
  State<MyTeamsPage> createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  TeamFilter _activeFilter = TeamFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<TeamEntity> _cachedTeams = [];
  List<PaymentEntity> _cachedPayments = [];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<MyTeamsBloc>().state;
    if (currentState is MyTeamsLoaded) {
      _cachedTeams = currentState.teams;
    }
    
    final paymentsState = context.read<PaymentsBloc>().state;
    if (paymentsState is PaymentsLoaded) {
      _cachedPayments = paymentsState.payments;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final int? currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<MyTeamsBloc>().add(LoadMyTeamsEvent());
                context.read<PaymentsBloc>().add(LoadMyPaymentsEvent());
              },
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mis Equipos',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MatchDaySearchBar(
                      controller: _searchController,
                      hintText: 'Buscar mis equipos...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<MyTeamsBloc, MyTeamsState>(
                    builder: (context, state) {
                      return MatchDayLoadingBar(
                        isLoading: state is MyTeamsLoading,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      );
                    },
                  ),
                  _buildFilters(isDark),
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
                            final filteredTeams = _getFilteredAndSearchedTeams(teamsToShow, currentUserId);
                            
                            if (myTeamsState is MyTeamsLoading && teamsToShow.isEmpty) {
                              return const MyTeamsSkeleton();
                            }

                            if (filteredTeams.isEmpty && myTeamsState is! MyTeamsLoading) {
                              return _buildEmptyState(isDark);
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              itemCount: filteredTeams.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final team = filteredTeams[index];
                                final isCaptain = currentUserId != null && team.captainId == currentUserId;

                                PaymentEntity? teamDebt;
                                for (final p in _cachedPayments) {
                                  if (p.teamName == team.name && p.estatusPago == 'pendiente') {
                                    teamDebt = p;
                                    break;
                                  }
                                }

                                return _buildPremiumTeamCard(
                                  context,
                                  team,
                                  isCaptain,
                                  teamDebt != null,
                                  teamDebt?.monto ?? 0.0,
                                  teamDebt?.currentSymbol ?? '\$',
                                  isDark,
                                ).animate()
                                 .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                                 .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                              },
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
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'my_teams_fab',
            onPressed: () => context.push('/crear-equipo'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add, weight: 900),
            label: const Text('NUEVO EQUIPO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
        );
      },
    );
  }

  Widget _buildFilters(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Todos', TeamFilter.all, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Jugador', TeamFilter.player, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Capitán', TeamFilter.capitan, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TeamFilter filter, bool isDark) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : (isDark ? Colors.grey[400] : Colors.black54),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTeamCard(
    BuildContext context,
    TeamEntity team,
    bool isCaptain,
    bool hasDebt,
    double debtAmount,
    String symbol,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                team.sportName.contains('Fútbol') ? Icons.sports_soccer : Icons.sports,
                size: 140,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.5)],
                          ),
                        ),
                        child: Hero(
                          tag: 'team_logo_${team.id}',
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: isDark ? Colors.black : Colors.white,
                            backgroundImage: (team.logo.isNotEmpty && !['⚽', '🏀', '🎾', 'null'].contains(team.logo)) 
                                ? NetworkImage(team.logo) 
                                : null,
                            child: (team.logo.isEmpty || ['⚽', '🏀', '🎾', 'null'].contains(team.logo))
                                ? Text(team.logo != 'null' && team.logo.isNotEmpty ? team.logo : '🛡️', style: const TextStyle(fontSize: 32))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.emoji_events_outlined, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Text(
                                  team.sportName,
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildPremiumRoleBadge(isCaptain, isDark),
                          ],
                        ),
                      ),
                      if (hasDebt) _buildPremiumDebtBadge(debtAmount, symbol),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          onTap: () => _handleContact(team.chatUrl),
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Chat',
                          isSecondary: true,
                          isDark: isDark,
                          enabled: team.chatUrl != null && team.chatUrl!.isNotEmpty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          onTap: () => context.push('/team-dashboard/${team.id}'),
                          icon: isCaptain ? Icons.settings_outlined : Icons.visibility_outlined,
                          label: isCaptain ? 'Gestionar' : 'Ver Perfil',
                          isSecondary: false,
                          isDark: isDark,
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
    );
  }

  Widget _buildPremiumRoleBadge(bool isCaptain, bool isDark) {
    final color = isCaptain ? AppColors.primary : Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCaptain ? Icons.stars_rounded : Icons.person_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isCaptain ? 'CAPITÁN' : 'JUGADOR',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDebtBadge(double amount, String symbol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Color(0xFFFF5252)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('DEUDA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          Text('$symbol${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isSecondary,
    required bool isDark,
    bool enabled = true,
  }) {
    if (isSecondary) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: enabled ? AppColors.primary.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: enabled ? AppColors.primary : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: enabled ? AppColors.primary : Colors.grey,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: enabled ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContact(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<TeamEntity> _getFilteredAndSearchedTeams(List<TeamEntity> teams, int? currentUserId) {
    List<TeamEntity> filtered = teams;
    if (currentUserId != null) {
      switch (_activeFilter) {
        case TeamFilter.all: break;
        case TeamFilter.player: filtered = teams.where((t) => t.captainId != currentUserId).toList(); break;
        case TeamFilter.capitan: filtered = teams.where((t) => t.captainId == currentUserId).toList(); break;
      }
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.name.toLowerCase().contains(_searchQuery) || 
        t.sportName.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_soccer_outlined, size: 80, color: AppColors.primary),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds).scale(duration: 1.seconds, begin: const Offset(1,1), end: const Offset(1.1,1.1), curve: Curves.easeInOut),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty ? 'No hay resultados' : '¡Aún no tienes equipo!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isNotEmpty 
                ? 'Prueba con otra búsqueda o ajusta los filtros.'
                : 'Únete a la liga, crea tu propio equipo y comienza a organizar encuentros épicos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
