import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/utils/match_role_resolver.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../widgets/match_details/match_detail_app_bar.dart';
import '../widgets/match_details/match_status_card.dart';
import '../widgets/match_details/match_map_preview.dart';
import '../widgets/match_details/match_info_card.dart';
import '../widgets/match_details/match_negotiation_card.dart';
import '../widgets/match_details/match_payments_status_card.dart';
import '../widgets/match_details/match_financial_card.dart';
import '../widgets/match_details/match_players_section.dart';
import '../widgets/match_details/match_confirmed_action_card.dart';
import '../widgets/match_details/match_result_section.dart';
import '../widgets/match_details/match_bottom_bar.dart';
import '../widgets/match_details/match_details_action_handler.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;
  const MatchDetailsPage({super.key, required this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<MatchPlayer> _players = [];
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    final repository = sl<IMatchesRepository>();
    final result = await repository.getMatchPlayers(widget.matchId);
    if (mounted) {
      result.fold(
        (_) => setState(() => _isLoadingPlayers = false),
        (players) => setState(() {
          _players = players;
          _isLoadingPlayers = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchDetailsEvent(widget.matchId)),
      child: BlocListener<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Partido cancelado con éxito'), backgroundColor: Colors.redAccent),
            );
            context.pop();
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            if (state is MatchesLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
            } else if (state is MatchDetailsLoaded) {
              return _buildContent(context, state.match, isDark);
            }
            return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MatchEntity match, bool isDark) {
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;

    final me = _players.where((p) => p.idUsuario == currentUserId).firstOrNull;
    final isPlayerInA = me?.idEquipo == match.idEquipoA;
    final isPlayerInB = me?.idEquipo == match.idEquipoB;

    final role = MatchRoleResolver.resolve(match, currentUserId ?? 0, isPlayerInA: isPlayerInA, isPlayerInB: isPlayerInB);
    final isOrganizer = role == MatchRole.captainA;
    final isAnyCaptain = role == MatchRole.captainA || role == MatchRole.captainB;

    final hasVerifiedPayment = me?.estatusPago == 'verificado';
    final hasReportedPayment = me?.urlReciboPago != null && me!.urlReciboPago!.isNotEmpty;
    final amIInA = _players.any((p) => p.idUsuario == currentUserId && p.idEquipo == match.idEquipoA) || match.idUsuarioOrg == currentUserId;

    final matchActions = MatchDetailsActionHandler.resolve(
      context: context, match: match, currentUserId: currentUserId, role: role,
      hasVerifiedPayment: hasVerifiedPayment, hasReportedPayment: hasReportedPayment, amIInA: amIInA,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          MatchDetailAppBar(match: match, isDark: isDark, isOrganizer: isOrganizer),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  children: [
                    MatchStatusCard(match: match, isDark: isDark, isOrganizer: isOrganizer)
                        .animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),

                    if (match.estatus == 'completada') ...[
                      MatchResultSection(match: match, isDark: isDark, currentUserId: currentUserId)
                          .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionHeader('UBICACIÓN', isDark),
                    const SizedBox(height: 12),
                    MatchMapPreview(match: match, isDark: isDark).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),

                    _buildSectionHeader('INFORMACIÓN', isDark),
                    const SizedBox(height: 12),
                    MatchInfoCard(match: match, isDark: isDark).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),

                    if (match.estatus == 'negociando') ...[
                      _buildSectionHeader('NEGOCIACIÓN', isDark),
                      const SizedBox(height: 12),
                      MatchNegotiationCard(match: match, isDark: isDark, isAnyCaptain: isAnyCaptain).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 24),
                    ],

                    if (match.estatus == 'pendiente_pago') ...[
                      _buildSectionHeader('ESTADO DE PAGOS', isDark),
                      const SizedBox(height: 12),
                      Builder(builder: (ctx) {
                        final myTeamId = amIInA ? match.idEquipoA : match.idEquipoB;
                        final rivalTeamId = amIInA ? match.idEquipoB : match.idEquipoA;
                        final myTeamPlayers = _players.where((p) => p.idEquipo == myTeamId).toList();
                        final rivalTeamPlayers = _players.where((p) => p.idEquipo == rivalTeamId).toList();
                        return MatchPaymentsStatusCard(
                          match: match, isDark: isDark, myTeamId: myTeamId ?? 0, rivalTeamId: rivalTeamId ?? 0,
                          myPaidCount: myTeamPlayers.where((p) => p.estatusPago == 'verificado').length, myTotalCount: myTeamPlayers.length,
                          rivalPaidCount: rivalTeamPlayers.where((p) => p.estatusPago == 'verificado').length, rivalTotalCount: rivalTeamPlayers.length,
                        );
                      }),
                      const SizedBox(height: 20),
                      MatchFinancialCard(match: match, isDark: isDark),
                      const SizedBox(height: 24),
                    ],

                    if (match.estatus == 'confirmada') ...[
                      _buildSectionHeader('ACCIÓN REQUERIDA', isDark),
                      const SizedBox(height: 12),
                      MatchConfirmedActionCard(match: match, isDark: isDark, isAnyCaptain: isAnyCaptain, currentUserId: currentUserId),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionHeader('JUGADORES', isDark),
                    const SizedBox(height: 12),
                    MatchPlayersSection(match: match, isDark: isDark, players: _players, isLoading: _isLoadingPlayers),
                    
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MatchBottomBar(actions: matchActions),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }
}
