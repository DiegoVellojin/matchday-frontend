import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../../payments/domain/entities/payment_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../payments/presentation/bloc/payments_state.dart';

class PlayerMatchDashboardPage extends StatefulWidget {
  final MatchEntity match;

  const PlayerMatchDashboardPage({super.key, required this.match});

  @override
  State<PlayerMatchDashboardPage> createState() => _PlayerMatchDashboardPageState();
}

class _PlayerMatchDashboardPageState extends State<PlayerMatchDashboardPage> {
  List<MatchPlayer> _players = [];
  bool _isLoadingPlayers = true;
  double _cuota = 0.0;
  late MatchEntity _currentMatch;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    _fetchPlayers();
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    final repository = context.read<IMatchesRepository>();
    final result = await repository.getMatchDetails(widget.match.id);
    result.fold(
      (_) => null,
      (match) {
        if (mounted) {
          setState(() {
            _currentMatch = match;
          });
        }
      },
    );
  }

  Future<void> _fetchPlayers() async {
    final repository = context.read<IMatchesRepository>();
    final result = await repository.getMatchPlayers(_currentMatch.id);

    if (mounted) {
      result.fold(
        (failure) => setState(() => _isLoadingPlayers = false),
        (players) {
          setState(() {
            _players = players;
            
            // Determinar mi equipo para calcular la cuota
            final profileState = context.read<ProfileBloc>().state;
            int? myTeamId;
            if (profileState is ProfileLoaded) {
              final myId = profileState.profile.id;
              // Si soy el organizador o estoy en equipo A
              final amIInA = players.any((p) => p.idUsuario == myId && p.idEquipo == _currentMatch.idEquipoA);
              myTeamId = amIInA ? _currentMatch.idEquipoA : _currentMatch.idEquipoB;
            }

            final myTeamPlayers = players.where((p) => p.idEquipo == (myTeamId ?? _currentMatch.idEquipoB)).toList();
            
            if (myTeamPlayers.isNotEmpty) {
              _cuota = _currentMatch.costoTotal / 2 / myTeamPlayers.length;
            } else {
              _cuota = _currentMatch.costoTotal / 22; // Backup
            }
            _isLoadingPlayers = false;
          });
        },
      );
    }
  }

  void _openGoogleMaps() async {
    final query = Uri.encodeComponent(_currentMatch.nombreCancha ?? 'Cancha de fútbol');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentsBloc, PaymentsState>(
          listener: (context, state) {
            if (state is ReceiptUploadedSuccess || state is PaymentVerifiedSuccess) {
              _fetchPlayers();
              _fetchMatchDetails();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detalles del Encuentro',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTeamsCard(context, isDark),
              const SizedBox(height: 20),
              _buildMatchInfoCard(context, isDark),
              const SizedBox(height: 20),
              _buildPaymentsStatusCard(context, isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context, isDark),
      ),
    );
  }

  Widget _buildTeamsCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    // Lógica para saber cuál es "Mi Equipo" y cuál el "Rival"
    final profileState = context.read<ProfileBloc>().state;
    bool amIInA = true;
    if (profileState is ProfileLoaded) {
      final myId = profileState.profile.id;
      amIInA = _players.any((p) => p.idUsuario == myId && p.idEquipo == widget.match.idEquipoA) || widget.match.idUsuarioOrg == myId;
    }

    final myName = amIInA ? (_currentMatch.nombreEquipoA ?? 'Mi Equipo') : (_currentMatch.nombreEquipoB ?? 'Mi Equipo');
    final myLogo = amIInA ? _currentMatch.logoEquipoA : _currentMatch.logoEquipoB;
    final rivalName = amIInA ? (_currentMatch.nombreEquipoB ?? 'Rival') : (_currentMatch.nombreEquipoA ?? 'Rival');
    final rivalLogo = amIInA ? _currentMatch.logoEquipoB : _currentMatch.logoEquipoA;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _teamAvatar(context, rivalLogo, 'R'),
              const Spacer(),
              const Text('VS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
              const Spacer(),
              _teamAvatar(context, myLogo, 'M'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  rivalName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  myName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamAvatar(BuildContext context, String? url, String label) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: theme.dividerColor)),
      child: ClipOval(
        child: url != null && url.isNotEmpty && url != 'null'
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Text(label, style: TextStyle(fontSize: 24, color: theme.colorScheme.onSurface))),
              )
            : Center(child: Text(label, style: TextStyle(fontSize: 24, color: theme.colorScheme.onSurface))),
      ),
    );
  }

  Widget _buildMatchInfoCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(context, Icons.calendar_today, 'Fecha', DateFormat('EEEE d MMMM', 'es_VE').format(_currentMatch.fechaInicioEstimada), isDark),
          Divider(color: theme.dividerColor, height: 24),
          _infoRow(context, Icons.access_time, 'Hora', '${DateFormat('jm').format(_currentMatch.fechaInicioEstimada)} - ${DateFormat('jm').format(_currentMatch.fechaFinEstimada)}', isDark),
          Divider(color: theme.dividerColor, height: 24),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentMatch.nombreCancha ?? 'Cancha por definir', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                    Text('Ver ubicación en el mapa', style: TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
            Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentsStatusCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    // Calculamos progreso de MI equipo
    final profileState = context.read<ProfileBloc>().state;
    int? myTeamId;
    int? rivalTeamId;
    if (profileState is ProfileLoaded) {
      final myId = profileState.profile.id;
      final amIInA = _players.any((p) => p.idUsuario == myId && p.idEquipo == _currentMatch.idEquipoA) || _currentMatch.idUsuarioOrg == myId;
      myTeamId = amIInA ? _currentMatch.idEquipoA : _currentMatch.idEquipoB;
      rivalTeamId = amIInA ? _currentMatch.idEquipoB : _currentMatch.idEquipoA;
    }

    // Datos mi equipo
    final myTeamPlayers = _players.where((p) => p.idEquipo == (myTeamId ?? widget.match.idEquipoB)).toList();
    final myPaidCount = myTeamPlayers.where((p) => p.estatusPago == 'verificado').length;
    final myTotalCount = myTeamPlayers.length;
    final everyonePaid = myPaidCount >= myTotalCount && myTotalCount > 0;

    // Datos rival
    final rivalTeamPlayers = _players.where((p) => p.idEquipo == rivalTeamId).toList();
    final rivalPaidCount = rivalTeamPlayers.where((p) => p.estatusPago == 'verificado').length;
    final rivalTotalCount = rivalTeamPlayers.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estado de Pagos', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
              if (!_isLoadingPlayers)
                Text(
                  'Cuota: \$${_cuota.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Mi Equipo
          _buildTeamProgress(everyonePaid ? '✓ Listo, esperando rival...' : '⏳ Esperando Pagos ($myPaidCount/$myTotalCount)', myPaidCount, myTotalCount, AppColors.primary, theme),
          const SizedBox(height: 16),
          
          // Equipo Rival
          _buildTeamProgress('Equipo Rival', rivalPaidCount, rivalTotalCount, Colors.cyan, theme),
          
          const SizedBox(height: 20),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          Text(
            _isLoadingPlayers ? 'Calculando cuota...' : 'Recuerda que el partido solo se confirmará cuando los 2 equipos estén al día.',
            style: TextStyle(color: textMuted, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamProgress(String label, int paid, int total, Color color, ThemeData theme) {
    final progress = total > 0 ? paid / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$paid de $total pagados', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.dividerColor,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    // Buscar mi estatus de pago para determinar el estado del botón
    final profileState = context.read<ProfileBloc>().state;
    MatchPlayer? me;
    if (profileState is ProfileLoaded && !_isLoadingPlayers) {
      final myId = profileState.profile.id;
      final matchingPlayers = _players.where((p) => p.idUsuario == myId);
      if (matchingPlayers.isNotEmpty) {
        me = matchingPlayers.first;
      }
    }

    final myStatus = me?.estatusPago ?? 'pendiente';
    final isVerified = myStatus == 'verificado';
    final isReported = myStatus == 'reportado';
    final isRejected = myStatus == 'rechazado';

    String buttonText = 'Realizar Pago';
    if (isVerified) {
      buttonText = 'Pago Verificado ✓';
    } else if (isReported || isRejected) {
      buttonText = 'Modificar Pago';
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isLoadingPlayers || isVerified) ? null : () {
              // Determinar mi equipo para los datos de navegación
              bool amIInA = true;
              if (profileState is ProfileLoaded) {
                final myId = profileState.profile.id;
                amIInA = _players.any((p) => p.idUsuario == myId && p.idEquipo == widget.match.idEquipoA) || widget.match.idUsuarioOrg == myId;
              }

              final myName = amIInA ? (widget.match.nombreEquipoA ?? 'Tu Equipo') : (widget.match.nombreEquipoB ?? 'Tu Equipo');
              final myLogo = amIInA ? widget.match.logoEquipoA : widget.match.logoEquipoB;

              final payment = PaymentEntity(
                idPartida: _currentMatch.id,
                teamName: myName,
                teamLogo: myLogo,
                concepto: _currentMatch.sportName ?? 'Partido de fútbol',
                monto: _cuota,
                isPaid: isVerified,
                estatusPago: myStatus,
                banco: amIInA ? _currentMatch.bancoReceptor : _currentMatch.bancoCapitanB,
                cedula: amIInA ? _currentMatch.cedulaReceptora : _currentMatch.cedulaCapitanB,
                telefono: amIInA ? _currentMatch.telefonoReceptor : _currentMatch.telefonoCapitanBPago,
              );
              context.push('/upload-receipt', extra: {'payment': payment});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isVerified ? theme.dividerColor : AppColors.primary,
              foregroundColor: isVerified ? theme.disabledColor : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              disabledBackgroundColor: theme.dividerColor,
            ),
            child: _isLoadingPlayers 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}


