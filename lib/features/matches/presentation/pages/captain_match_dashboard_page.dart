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
  List<MatchPlayer> _players = [];
  bool _isLoadingPlayers = true;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    final repository = context.read<IMatchesRepository>();
    final result = await repository.getMatchPlayers(widget.matchEntity.id);

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
      partidaId: widget.matchEntity.id,
    );
  }

  Future<void> _openMap() async {
    final match = widget.matchEntity;
    // Aquí podrías usar latitud/longitud si estuvieran en el entity, 
    // por ahora usamos el nombre de la cancha
    final query = Uri.encodeComponent(match.nombreCancha ?? 'Cancha #${match.idCancha}');
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.matchEntity;

    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final isCaptainA =
        currentUserId != null && match.idUsuarioOrg == currentUserId;
    final isCaptainB =
        currentUserId != null && match.idCapitanB == currentUserId;

    final myTeamId = isCaptainA ? match.idEquipoA : (isCaptainB ? match.idEquipoB : null);
    final rivalTeamId = isCaptainA ? match.idEquipoB : (isCaptainB ? match.idEquipoA : null);

    final myTeamPlayers = _players.where((p) => p.idEquipo == myTeamId).toList();
    final rivalTeamPlayers = _players.where((p) => p.idEquipo == rivalTeamId).toList();

    final myTeamPaid = myTeamPlayers.where((p) => p.estatusPago == 'verificado').length;
    final rivalTeamPaid = rivalTeamPlayers.where((p) => p.estatusPago == 'verificado').length;

    final cuota = myTeamPlayers.isNotEmpty 
        ? (match.costoTotal / 2 / myTeamPlayers.length) 
        : (match.costoTotal / 22);

    final everyonePaid = myTeamPaid >= myTeamPlayers.length && myTeamPlayers.isNotEmpty;
    final amIReady = isCaptainA ? match.equipoAListo : (isCaptainB ? match.equipoBListo : false);
    final isConfirmed = match.estatus == 'confirmada';
    
    final myGolesFavor = isCaptainA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
    final hasRegisteredResult = myGolesFavor != null;

    return MultiBlocListener(
      listeners: [
        BlocListener<MatchesBloc, MatchesState>(
          listener: (context, state) {
            if (state is TeamMarkedReady) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('¡Equipo marcado como listo! 🎉'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            }
            if (state is MatchResultRegistered) {
              Navigator.pop(context);
            }
          },
        ),
        BlocListener<PaymentsBloc, PaymentsState>(
          listener: (context, state) {
            if (state is PaymentVerifiedSuccess) {
              _fetchPlayers(); // Recargar lista al verificar un pago
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
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          final bg = theme.scaffoldBackgroundColor;
          final surface = colorScheme.surface;
          final accent = colorScheme.primary;
          final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
          final textMain = colorScheme.onSurface;

          return Scaffold(
            backgroundColor: bg,
            body: Column(
              children: [
                _buildHeader(context, match, myTeamPaid, myTeamPlayers.length, rivalTeamPaid, rivalTeamPlayers.length, surface, textMain, textMuted, accent),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlayersList(myTeamPlayers, cuota, true, accent, surface, textMain, textMuted),
                      _buildPlayersList(rivalTeamPlayers, cuota, false, accent, surface, textMain, textMuted),
                    ],
                  ),
                ),
                _buildStickyFooter(everyonePaid, myTeamPaid, myTeamPlayers.length, surface, accent, textMuted, amIReady, isConfirmed, hasRegisteredResult, currentUserId),
              ],
            ),
          );
        }
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
    final dateFormat = DateFormat('EEE d/MM');
    final formattedDate = dateFormat.format(match.fechaInicioEstimada);

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 16),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: textMain),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard de Capitán',
                    style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Seguimiento de pagos',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Resumen del Partido
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Hero(
                        tag: 'team_logo_${match.idEquipoA}_match_${match.id}',
                        child: ClipOval(
                          child: (match.logoEquipoA != null && match.logoEquipoA!.isNotEmpty && match.logoEquipoA != 'null')
                              ? Image.network(
                                  match.logoEquipoA!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                                )
                              : const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match.nombreEquipoA ?? 'Team A'} vs ${match.nombreEquipoB ?? 'Team B'}',
                            style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            match.sportName ?? 'Fútbol',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _openMap,
                      icon: Icon(Icons.map_outlined, color: accent),
                      tooltip: 'Ver en mapa',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildInfoItem('Fecha', Icons.calendar_today, formattedDate, textMuted, textMain, accent)),
                    Expanded(child: _buildInfoItem('Ubicación', Icons.location_on, match.nombreCancha ?? 'Campo', textMuted, textMain, accent)),
                    Expanded(child: _buildInfoItem('Costo Total', Icons.attach_money, '\$${match.costoTotal.toStringAsFixed(0)}', textMuted, textMain, accent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Custom Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Mi Equipo ($myPaid/$myTotal)', accent, textMuted),
                _buildTabButton(1, 'Equipo Rival ($rivalPaid/$rivalTotal)', accent, textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, IconData icon, String value, Color textMuted, Color textMain, Color accent) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, Color accent, Color textMuted) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : textMuted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<MatchPlayer> players, double cuota, bool isMyTeam, Color accent, Color surface, Color textMain, Color textMuted) {
    if (_isLoadingPlayers) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: surface,
          highlightColor: Theme.of(context).dividerColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cuota por Jugador', style: TextStyle(color: textMuted, fontSize: 12)),
                  Text('\$${cuota.toStringAsFixed(2)}', style: TextStyle(color: accent, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.attach_money, color: accent, size: 32),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMyTeam ? 'Jugadores de Mi Equipo' : 'Jugadores del Equipo Rival',
                style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (players.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No hay jugadores aún', style: TextStyle(color: textMuted))),
                )
              else
                ...players.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  return _buildPlayerRow(p, cuota, isMyTeam, accent, textMain, textMuted)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(MatchPlayer player, double cuota, bool isMyTeam, Color accent, Color textMain, Color textMuted) {
    final isPaid = player.estatusPago == 'verificado';
    final hasReceipt = player.urlReciboPago != null && player.urlReciboPago!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Hero(
            tag: 'player_avatar_${widget.matchEntity.id}_${player.idUsuario}',
            child: CircleAvatar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundImage: (player.urlFotoPerfil != null && player.urlFotoPerfil!.isNotEmpty && player.urlFotoPerfil != 'null')
                  ? NetworkImage(player.urlFotoPerfil!)
                  : null,
              child: (player.urlFotoPerfil == null || player.urlFotoPerfil!.isEmpty || player.urlFotoPerfil == 'null')
                  ? const Text('👤', style: TextStyle(fontSize: 18))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.nombreUsuario,
              style: TextStyle(color: textMain, fontWeight: FontWeight.w500),
            ),
          ),
          if (isPaid)
            _statusChip(accent, Icons.check_circle, 'Pagado')
          else if (isMyTeam && hasReceipt)
            ElevatedButton.icon(
              onPressed: () => _handleVerifyPayment(player, cuota),
              icon: const Icon(Icons.visibility, size: 14),
              label: const Text('Revisar', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          else
            _statusChip(const Color(0xFFFFA500), Icons.access_time, 'Pendiente'),
        ],
      ),
    );
  }

  Widget _statusChip(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(bool everyonePaid, int paidCount, int totalCount, Color surface, Color accent, Color textMuted, bool amIReady, bool isConfirmed, bool hasRegisteredResult, int? currentUserId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBouncingButton(
            onTap: isConfirmed 
                ? () {
                    if (hasRegisteredResult) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmarResultadoPage(
                            match: widget.matchEntity,
                            currentUserId: currentUserId!,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterResultPage(
                            match: widget.matchEntity,
                            currentUserId: currentUserId!,
                          ),
                        ),
                      );
                    }
                  }
                : (everyonePaid && !amIReady)
                    ? () => context.read<MatchesBloc>().add(MarkTeamReadyEvent(widget.matchEntity.id))
                    : null,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: isConfirmed 
                    ? AppColors.primary 
                    : (amIReady ? Theme.of(context).dividerColor : (everyonePaid ? accent : Theme.of(context).dividerColor)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: (everyonePaid && !amIReady) ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              alignment: Alignment.center,
              child: Text(
                isConfirmed 
                    ? (hasRegisteredResult ? '👀 Ver Resultado' : '🏆 Registrar Resultado')
                    : (amIReady 
                        ? '✓ Listo, esperando rival...' 
                        : (everyonePaid ? '✓ Confirmar Equipo Ready' : '⏳ Esperando Pagos ($paidCount/$totalCount)')),
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: (everyonePaid || isConfirmed) ? Colors.black : textMuted,
                ),
              ),
            ),
          ).withPulseGlow(color: accent, enabled: everyonePaid && !amIReady),
          if (everyonePaid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '¡Todos han pagado! Tu equipo está listo para jugar',
                style: TextStyle(color: accent, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
