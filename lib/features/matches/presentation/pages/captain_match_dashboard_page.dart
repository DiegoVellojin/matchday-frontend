import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import 'register_result_page.dart';
import 'confirm_result_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../payments/presentation/bloc/payments_state.dart';
import '../../../payments/presentation/widgets/verify_payment_modal.dart';

class CaptainMatchDashboardPage extends StatefulWidget {
  final MatchEntity matchEntity;

  const CaptainMatchDashboardPage({super.key, required this.matchEntity});

  @override
  State<CaptainMatchDashboardPage> createState() =>
      _CaptainMatchDashboardPageState();
}

class _CaptainMatchDashboardPageState extends State<CaptainMatchDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MatchEntity _match;
  List<MatchPlayer> _players = [];
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _match = widget.matchEntity;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    await Future.wait([
      _fetchPlayers(),
      _fetchMatchDetails(),
    ]);
  }

  Future<void> _fetchMatchDetails() async {
    final repository = context.read<IMatchesRepository>();
    final result = await repository.getMatchDetails(_match.id);
    
    if (mounted) {
      result.fold(
        (failure) => null,
        (updatedMatch) {
          setState(() {
            _match = updatedMatch;
          });
        },
      );
    }
  }

  Future<void> _fetchPlayers() async {
    final repository = context.read<IMatchesRepository>();
    final result = await repository.getMatchPlayers(_match.id);

    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoadingPlayers = false);
        },
        (players) {
          setState(() {
            _players = players;
            _isLoadingPlayers = false;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleVerifyPayment(MatchPlayer player, double cuota) {
    VerifyPaymentModal.show(
      context,
      jugador: {
        'id': player.idUsuario,
        'nombre': player.nombreUsuario,
        'url_foto_perfil': player.urlFotoPerfil ?? '',
        'url_recibo_pago': player.urlReciboPago ?? '',
        'referencia': player.referenciaPago ?? '',
      },
      monto: cuota,
      partidaId: _match.id,
    );
  }

  Future<void> _openMap() async {
    final match = _match;
    final query = Uri.encodeComponent(match.nombreCancha ?? 'Cancha #${match.idCancha}');
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = _match;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final isCaptainA = currentUserId != null && match.idUsuarioOrg == currentUserId;
    final isCaptainB = currentUserId != null && match.idCapitanB == currentUserId;

    final myTeamId = isCaptainA ? match.idEquipoA : (isCaptainB ? match.idEquipoB : null);
    final rivalTeamId = isCaptainA ? match.idEquipoB : (isCaptainB ? match.idEquipoA : null);

    final myTeamPlayers = _players.where((p) => p.idEquipo == myTeamId).toList();
    final rivalTeamPlayers = _players.where((p) => p.idEquipo == rivalTeamId).toList();

    final myTeamPaid = myTeamPlayers.where((p) => p.estatusPago == 'verificado').length;
    final rivalTeamPaid = rivalTeamPlayers.where((p) => p.estatusPago == 'verificado').length;

    final everyonePaid = myTeamPaid >= myTeamPlayers.length && myTeamPlayers.isNotEmpty;
    final amIReady = isCaptainA ? match.equipoAListo : (isCaptainB ? match.equipoBListo : false);
    final isConfirmed = match.estatus == 'confirmada';
    
    final myGolesFavor = isCaptainA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
    final hasRegisteredResult = myGolesFavor != null;

    final bg = theme.scaffoldBackgroundColor;
    final surface = colorScheme.surface;
    final accent = AppColors.primary;
    final textMuted = isDark ? AppColors.textMuted : Colors.black54;
    final textMain = colorScheme.onSurface;

    return MultiBlocListener(
      listeners: [
        BlocListener<MatchesBloc, MatchesState>(
          listener: (context, state) {
            if (state is TeamMarkedReady) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Equipo marcado como listo! 🎉'),
                  backgroundColor: AppColors.primary,
                ),
              );
              _fetchMatchDetails();
            }
          },
        ),
        BlocListener<PaymentsBloc, PaymentsState>(
          listener: (context, state) {
            if (state is PaymentVerifiedSuccess) {
              _refreshAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pago verificado correctamente ✅'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            _buildHeader(context, match, myTeamPaid, myTeamPlayers.length, rivalTeamPaid, rivalTeamPlayers.length, surface, textMain, textMuted, accent),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlayersList(myTeamPlayers, match.cuotaPorJugador, true, accent, surface, textMain, textMuted),
                  _buildPlayersList(rivalTeamPlayers, match.cuotaPorJugador, false, accent, surface, textMain, textMuted),
                ],
              ),
            ),
            _buildStickyFooter(everyonePaid, myTeamPaid, myTeamPlayers.length, surface, accent, textMuted, amIReady, isConfirmed, hasRegisteredResult, currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, 
    MatchEntity match, 
    int myPaid, 
    int myTotal, 
    int rivalPaid, 
    int rivalTotal,
    Color surface,
    Color textMain,
    Color textMuted,
    Color accent,
  ) {
    final formattedDate = DateFormat('EEE d/MM').format(match.fechaInicioEstimada);

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                style: IconButton.styleFrom(backgroundColor: AppColors.border.withValues(alpha: 0.5)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de pagos',
                    style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  Text(
                    'Control administrativo del encuentro',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMatchSummaryCard(match, formattedDate, textMain, textMuted, accent)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
          const SizedBox(height: 20),
          _buildTabIndicator(myPaid, myTotal, rivalPaid, rivalTotal, accent, textMuted),
        ],
      ),
    );
  }

  Widget _buildMatchSummaryCard(MatchEntity match, String date, Color textMain, Color textMuted, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSmallLogo(match.logoEquipoA),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.nombreEquipoA} vs ${match.nombreEquipoB}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(match.sportName ?? 'Fútbol', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _openMap,
                icon: const Icon(Icons.location_on_outlined, size: 20),
                color: accent,
                style: IconButton.styleFrom(backgroundColor: accent.withValues(alpha: 0.1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniInfo(Icons.calendar_today, date, 'Fecha', accent, textMuted),
              _buildMiniInfo(Icons.stadium_outlined, match.nombreCancha ?? 'Campo', 'Sede', accent, textMuted),
              _buildMiniInfo(Icons.payments_outlined, '\$${match.costoTotal.toStringAsFixed(0)}', 'Total', accent, textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String value, String label, Color accent, Color textMuted) {
    return Column(
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
      ],
    );
  }

  Widget _buildSmallLogo(String? url) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty && url != 'null')
            ? Image.network(url, fit: BoxFit.cover)
            : const Center(child: Text('⚽')),
      ),
    );
  }

  Widget _buildTabIndicator(int myPaid, int myTotal, int rivalPaid, int rivalTotal, Color accent, Color textMuted) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabItem(0, 'Mi Equipo', '$myPaid/$myTotal', accent, textMuted),
          _tabItem(1, 'Rival', '$rivalPaid/$rivalTotal', accent, textMuted),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, String count, Color accent, Color textMuted) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black.withValues(alpha: 0.1) : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<MatchPlayer> players, double cuota, bool isMyTeam, Color accent, Color surface, Color textMain, Color textMuted) {
    if (_isLoadingPlayers) return _buildShimmerList(surface);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCuotaHeader(cuota, accent, textMuted),
        const SizedBox(height: 20),
        Text(
          isMyTeam ? 'Integrantes de tu equipo' : 'Integrantes del equipo rival',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 12),
        ...players.asMap().entries.map((entry) {
          return _buildPlayerCard(entry.value, cuota, isMyTeam, accent, textMain, textMuted)
              .animate()
              .fadeIn(duration: 400.ms, delay: (entry.key * 50).ms)
              .slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildCuotaHeader(double cuota, Color accent, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recaudación por jugador', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('\$${cuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.account_balance_wallet, color: Colors.black26, size: 40),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(MatchPlayer player, double cuota, bool isMyTeam, Color accent, Color textMain, Color textMuted) {
    final isPaid = player.estatusPago == 'verificado';
    final hasReceipt = player.urlReciboPago != null && player.urlReciboPago!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPaid ? accent.withValues(alpha: 0.3) : Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: (player.urlFotoPerfil != null && player.urlFotoPerfil!.isNotEmpty)
                ? NetworkImage(player.urlFotoPerfil!)
                : null,
            child: (player.urlFotoPerfil == null || player.urlFotoPerfil!.isEmpty)
                ? const Icon(Icons.person, color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(isPaid ? 'Pago verificado' : (hasReceipt ? 'Recibo pendiente' : 'Sin reporte'), 
                     style: TextStyle(color: isPaid ? accent : textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (isPaid)
            Icon(Icons.check_circle, color: accent, size: 24)
          else if (isMyTeam && hasReceipt)
            AnimatedBouncingButton(
              onTap: () => _handleVerifyPayment(player, cuota),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Revisar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Pendiente', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(Color surface) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surface,
        highlightColor: Theme.of(context).dividerColor,
        child: Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildStickyFooter(bool everyonePaid, int paidCount, int totalCount, Color surface, Color accent, Color textMuted, bool amIReady, bool isConfirmed, bool hasRegisteredResult, int? currentUserId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isConfirmed && !everyonePaid)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(
                value: totalCount > 0 ? paidCount / totalCount : 0,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
            ),
          AnimatedBouncingButton(
            onTap: isConfirmed 
                ? () {
                    if (hasRegisteredResult) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmarResultadoPage(match: _match, currentUserId: currentUserId!)));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterResultPage(match: widget.matchEntity, currentUserId: currentUserId!)));
                    }
                  }
                : (everyonePaid && !amIReady)
                    ? () => context.read<MatchesBloc>().add(MarkTeamReadyEvent(widget.matchEntity.id))
                    : null,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: (isConfirmed || (everyonePaid && !amIReady))
                    ? LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)])
                    : null,
                color: (isConfirmed || (everyonePaid && !amIReady)) ? null : AppColors.border,
                borderRadius: BorderRadius.circular(20),
                boxShadow: (everyonePaid && !amIReady) ? [
                  BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))
                ] : [],
              ),
              alignment: Alignment.center,
              child: Text(
                isConfirmed 
                    ? (hasRegisteredResult ? '👀 Ver Resultado' : '🏆 Registrar Resultado')
                    : (amIReady 
                        ? 'Esperando rival...' 
                        : (everyonePaid ? '¡Confirmar Equipo Listo!' : 'Faltan pagos ($paidCount/$totalCount)')),
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 17,
                  color: (everyonePaid || isConfirmed) ? Colors.black : textMuted,
                ),
              ),
            ),
          ).withPulseGlow(color: accent, enabled: everyonePaid && !amIReady),
        ],
      ),
    );
  }
}
