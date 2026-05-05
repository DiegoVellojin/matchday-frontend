import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
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

  static const Color bgDark = Color(0xFF151515);
  static const Color containerDark = Color(0xFF1E1E1E);
  static const Color accentGreen = Color(0xFF39CEA5);
  static const Color textSecondary = Color(0xFF9CA3AF);

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

    return BlocListener<MatchesBloc, MatchesState>(
      listener: (context, state) {
        if (state is TeamMarkedReady) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Equipo marcado como listo! 🎉'),
              backgroundColor: accentGreen,
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Column(
          children: [
            _buildHeader(context, match, myTeamPaid, myTeamPlayers.length, rivalTeamPaid, rivalTeamPlayers.length),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlayersList(myTeamPlayers, cuota, true),
                  _buildPlayersList(rivalTeamPlayers, cuota, false),
                ],
              ),
            ),
            _buildStickyFooter(everyonePaid, myTeamPaid, myTeamPlayers.length),
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
    int rivalTotal
  ) {
    final dateFormat = DateFormat('EEE d/MM');
    final formattedDate = dateFormat.format(match.fechaInicioEstimada);

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 16),
      decoration: const BoxDecoration(
        color: containerDark,
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard de Capitán',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Seguimiento de pagos',
                    style: TextStyle(color: textSecondary, fontSize: 12),
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('⚽', style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match.nombreEquipoA ?? 'Team A'} vs ${match.nombreEquipoB ?? 'Team B'}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            match.sportName ?? 'Fútbol',
                            style: const TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_outlined, color: accentGreen),
                      tooltip: 'Ver en mapa',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildInfoItem('Fecha', Icons.calendar_today, formattedDate)),
                    Expanded(child: _buildInfoItem('Ubicación', Icons.location_on, match.nombreCancha ?? 'Campo')),
                    Expanded(child: _buildInfoItem('Costo Total', Icons.attach_money, '\$${match.costoTotal.toStringAsFixed(0)}')),
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Mi Equipo ($myPaid/$myTotal)'),
                _buildTabButton(1, 'Equipo Rival ($rivalPaid/$rivalTotal)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, IconData icon, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: accentGreen),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<MatchPlayer> players, double cuota, bool isMyTeam) {
    if (_isLoadingPlayers) {
      return const Center(child: CircularProgressIndicator(color: accentGreen));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cuota Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cuota por Jugador', style: TextStyle(color: textSecondary, fontSize: 12)),
                  Text('\$${cuota.toStringAsFixed(2)}', style: const TextStyle(color: accentGreen, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.attach_money, color: accentGreen, size: 32),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: containerDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMyTeam ? 'Jugadores de Mi Equipo' : 'Jugadores del Equipo Rival',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (players.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No hay jugadores aún', style: TextStyle(color: textSecondary))),
                )
              else
                ...players.map((p) => _buildPlayerRow(p, cuota, isMyTeam)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(MatchPlayer player, double cuota, bool isMyTeam) {
    final isPaid = player.estatusPago == 'verificado';
    final hasReceipt = player.urlReciboPago != null && player.urlReciboPago!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2A2A2A),
            backgroundImage: (player.urlFotoPerfil?.startsWith('http') ?? false)
                ? NetworkImage(player.urlFotoPerfil!)
                : null,
            child: !(player.urlFotoPerfil?.startsWith('http') ?? false)
                ? const Text('👤', style: TextStyle(fontSize: 18))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.nombreUsuario,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          if (isPaid)
            _statusChip(accentGreen, Icons.check_circle, 'Pagado')
          else if (isMyTeam && hasReceipt)
            ElevatedButton.icon(
              onPressed: () => _handleVerifyPayment(player, cuota),
              icon: const Icon(Icons.visibility, size: 14),
              label: const Text('Revisar', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                foregroundColor: accentGreen,
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

  Widget _buildStickyFooter(bool everyonePaid, int paidCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: containerDark,
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: everyonePaid
                  ? () => context.read<MatchesBloc>().add(MarkTeamReadyEvent(widget.matchEntity.id))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: everyonePaid ? accentGreen : const Color(0xFF2A2A2A),
                foregroundColor: everyonePaid ? Colors.black : textSecondary,
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                disabledForegroundColor: textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: everyonePaid ? 20 : 0,
                shadowColor: accentGreen.withValues(alpha: 0.5),
              ),
              child: Text(
                everyonePaid ? '✓ Confirmar Equipo Ready' : '⏳ Esperando Pagos ($paidCount/$totalCount)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          if (everyonePaid)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '¡Todos han pagado! Tu equipo está listo para jugar',
                style: TextStyle(color: accentGreen, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
