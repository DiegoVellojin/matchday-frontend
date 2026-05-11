import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_status.dart';
import '../../domain/utils/match_role_resolver.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../payments/domain/entities/payment_entity.dart';

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

  void _handleContactar(MatchEntity match) async {
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final rivalPhone = isCaptainA
        ? match.telefonoCapitanB
        : match.telefonoCapitanA;

    if (rivalPhone == null || rivalPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay número de teléfono disponible para el capitán rival',
          ),
        ),
      );
      return;
    }

    final cleanPhone = rivalPhone.replaceAll(RegExp(r'\D'), '');
    final message =
        "Hola, soy el capitán rival para el partido del ${DateFormat('dd/MM/yyyy').format(match.fechaInicioEstimada)}. ¿Cómo coordinamos?";
    final url =
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  void _handleCancelMatch(int matchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          '¿Cancelar Partido?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Esta acción eliminará el partido permanentemente y notificará a los interesados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MatchesBloc>().add(CancelMatchEvent(matchId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Confirmar Cancelación',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) =>
          sl<MatchesBloc>()..add(LoadMatchDetailsEvent(widget.matchId)),
      child: BlocListener<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Partido cancelado con éxito'),
                backgroundColor: AppColors.error,
              ),
            );
            context.pop();
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            if (state is MatchesLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            } else if (state is MatchDetailsLoaded) {
              return _buildContent(context, state.match, isDark);
            }
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final role = MatchRoleResolver.resolve(match, currentUserId ?? 0);
    final isOrganizer = role == MatchRole.captainA;
    final isAnyCaptain =
        role == MatchRole.captainA || role == MatchRole.captainB;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(match, isDark, isOrganizer),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMainStatusCard(match, isDark, isOrganizer)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  if (match.estatus == 'completada') ...[
                    _buildResultSection(match, isDark, currentUserId)
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.easeOutBack)
                        .shimmer(
                          duration: 2.seconds,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                    const SizedBox(height: 16),
                  ],

                  _buildMapPreview(
                    match,
                    isDark,
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                  const SizedBox(height: 16),

                  _buildMatchInfoCard(
                    match,
                    isDark,
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                  const SizedBox(height: 16),

                  if (match.estatus == 'negociando')
                    _buildNegotiationCard(
                      context,
                      match,
                      isDark,
                      isAnyCaptain,
                    ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  if (match.estatus == 'pendiente_pago')
                    _buildPaymentsStatusCard(
                      context,
                      match,
                      isDark,
                    ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  if (match.estatus == 'confirmada')
                    _buildConfirmedActionCard(
                      match,
                      isDark,
                      isAnyCaptain,
                      currentUserId,
                    ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  if (match.estatus == 'pendiente_pago')
                    _buildFinancialCard(
                      match,
                      isDark,
                    ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  const SizedBox(height: 16),
                  _buildPlayersSection(
                    isDark,
                    match,
                  ).animate().fadeIn(duration: 800.ms, delay: 700.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        context,
        match,
        isDark,
        isOrganizer,
        isAnyCaptain,
        role,
      ),
    );
  }

  Widget _buildSliverAppBar(MatchEntity match, bool isDark, bool isOrganizer) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.sportName?.toUpperCase() ?? 'PARTIDO',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              match.nombreEquipoA != null
                  ? '${match.nombreEquipoA} vs ${match.nombreEquipoB ?? '(Esperando rival)'}'
                  : 'Detalles del Encuentro',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(_getSportImage(match.sportName), fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isOrganizer &&
            (match.estatus == 'publicada' || match.estatus == 'negociando'))
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _handleCancelMatch(match.id),
          ),
      ],
    );
  }

  String _getSportImage(String? sportName) {
    final name = sportName?.toLowerCase() ?? '';

    // Fútbol (11, 5, etc.)
    if (name.contains('futbol') ||
        name.contains('fútbol') ||
        name.contains('soccer')) {
      return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000';
    }
    // Basketball
    if (name.contains('basket') || name.contains('baloncesto')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=1000';
    }
    // Volleyball
    if (name.contains('volley') || name.contains('voleibol')) {
      return 'https://images.unsplash.com/photo-1666901356149-93f2eb3ba5a2?q=80&w=1000';
    }
    // Tennis
    if (name.contains('tennis') || name.contains('tenis')) {
      return 'https://images.unsplash.com/flagged/photo-1576972405668-2d020a01cbfa?q=80&w=1000';
    }
    // Padel / Pickleball
    if (name.contains('padel') ||
        name.contains('pádel') ||
        name.contains('pickleball')) {
      return 'https://images.unsplash.com/photo-1657704358775-ed705c7388d2?q=80&w=1000';
    }
    // Béisbol / Softbol
    if (name.contains('beisbol') ||
        name.contains('béisbol') ||
        name.contains('softbol') ||
        name.contains('baseball')) {
      return 'https://images.unsplash.com/photo-1578432014316-48b448d79d57?q=80&w=1000';
    }
    // Rugby
    if (name.contains('rugby')) {
      return 'https://images.unsplash.com/photo-1529663297269-6d349ec39b57?q=80&w=1000';
    }
    // Ping Pong
    if (name.contains('ping') || name.contains('mesa')) {
      return 'https://images.unsplash.com/photo-1534158914592-062992fbe900?q=80&w=1000';
    }
    // Futsal / Fútbol Sala
    if (name.contains('futsal') || name.contains('sala')) {
      return 'https://images.unsplash.com/photo-1587384474964-3a06ce1ce699?q=80&w=1000';
    }

    // Default: Fútbol
    return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1000';
  }

  Widget _buildMainStatusCard(
    MatchEntity match,
    bool isDark,
    bool isOrganizer,
  ) {
    String statusTitle = match.status.label;
    String statusDesc = "Sigue el proceso del partido.";
    IconData statusIcon = match.status.icon;
    Color statusColor = match.status.color;

    if (match.status is PublishedStatus) {
      statusTitle = isOrganizer ? "Esperando Oponente" : "Partido Disponible";
      statusDesc = isOrganizer
          ? "Tu partido ha sido publicado. Pronto un capitán te retará."
          : "¡Reta a este equipo y organiza el encuentro!";
    } else if (match.status is NegotiatingStatus) {
      statusDesc = "Coordinando fecha y costos finales entre capitanes.";
    } else if (match.status is PendingPaymentStatus) {
      statusDesc =
          "Los términos fueron aceptados. Realiza tu pago para confirmar.";
    } else if (match.status is CompletedStatus) {
      statusTitle = "Partido Finalizado";
      statusDesc = "El encuentro ha concluido. Mira el marcador final.";
    } else if (match.status is CancelledStatus) {
      statusDesc = "Este partido ha sido cancelado.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.surface, AppColors.surface.withValues(alpha: 0.8)]
              : [Colors.white, Colors.white.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(MatchEntity match, bool isDark) {
    if (match.latitudCancha != null && match.longitudCancha != null) {
      final position = LatLng(match.latitudCancha!, match.longitudCancha!);
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
                markers: {
                  Marker(markerId: const MarkerId('court'), position: position),
                },
                liteModeEnabled: true, // Optimizado para previews
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (_) => _openInGoogleMaps(match),
              ),
              PositionDetector(onTap: () => _openInGoogleMaps(match)),
              Positioned(
                bottom: 12,
                right: 12,
                child: FloatingActionButton.small(
                  onPressed: () => _openInGoogleMaps(match),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.directions, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildMapPlaceholder(match);
  }

  Widget _buildMapPlaceholder(MatchEntity match) {
    return GestureDetector(
      onTap: () => _openInGoogleMaps(match),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 48),
            SizedBox(height: 8),
            Text(
              'Abrir en Google Maps',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInGoogleMaps(MatchEntity match) async {
    final query = match.nombreCancha ?? 'Cancha #${match.idCancha}';
    final url = match.latitudCancha != null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${match.latitudCancha},${match.longitudCancha}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
          );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMatchInfoCard(MatchEntity match, bool isDark) {
    return _buildCard(
      isDark,
      child: Column(
        children: [
          Row(
            children: [
              _buildTeamAvatar(match.logoEquipoA, 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.nombreEquipoA ?? 'Equipo Organizador',
                      style: _titleStyle(isDark, context),
                    ),
                    Text(
                      'Organizado por ${match.nombreCapitanA ?? 'Capi'}',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.sportName ?? 'Fútbol',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            DateFormat(
              'EEEE, d MMMM • hh:mm a',
            ).format(match.fechaInicioEstimada),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on_rounded,
            match.nombreCancha ?? 'Ubicación pendiente',
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.attach_money_rounded,
            'Costo estimado: \$${match.costoTotal}',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAvatar(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: ClipOval(
        child: (url != null && url.startsWith('http'))
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) =>
                    const Icon(Icons.sports_soccer, size: 28),
              )
            : const Icon(Icons.sports_soccer, size: 28),
      ),
    );
  }

  Widget _buildNegotiationCard(
    BuildContext context,
    MatchEntity match,
    bool isDark,
    bool isAnyCaptain,
  ) {
    // Si los términos no han sido acordados y no es capitán, mostrar mensaje
    final hasTerms = match.costoTotal > 0 && match.fechaAcordada != null;

    if (!isAnyCaptain && !hasTerms) {
      return _buildCard(
        isDark,
        child: Column(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.orange, size: 32),
            const SizedBox(height: 12),
            Text('En espera de capitanes', style: _titleStyle(isDark, context)),
            const SizedBox(height: 8),
            const Text(
              'Los capitanes están acordando el costo y la fecha final del encuentro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final propA = match.propuestaCostoA != null;
    final propB = match.propuestaCostoB != null;
    final coincide =
        propA && propB && match.propuestaCostoA == match.propuestaCostoB;

    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                coincide
                    ? Icons.check_circle_outline
                    : Icons.handshake_outlined,
                color: coincide ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Estado de la Negociación',
                style: _titleStyle(isDark, context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProposalRow(
            'Capitán A (Organizador)',
            match.propuestaCostoA,
            match.propuestaFechaA,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildProposalRow(
            'Capitán B (Rival)',
            match.propuestaCostoB,
            match.propuestaFechaB,
            isDark,
          ),
          if (propA && propB && !coincide)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los montos o fechas no coinciden. Usa "Coordinar Encuentro" para ajustar tu propuesta.',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProposalRow(
    String label,
    double? costo,
    DateTime? fecha,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 13)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              costo != null ? '\$${costo.toStringAsFixed(2)}' : 'Sin propuesta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: costo != null
                    ? theme.colorScheme.onSurface
                    : textMuted.withValues(alpha: 0.5),
              ),
            ),
            if (fecha != null)
              Text(
                DateFormat('dd/MM - HH:mm').format(fecha),
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard(MatchEntity match, bool isDark) {
    final totalPlayers = match.cuposTotales;
    final quota = match.cuotaPorJugador;
    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen Financiero', style: _titleStyle(isDark, context)),
          const SizedBox(height: 16),
          _buildFinancialRow(
            'Alquiler de Cancha',
            '\$${match.costoTotal}',
            isDark,
          ),
          _buildFinancialRow('Jugadores Totales', '$totalPlayers', isDark),
          Divider(color: Theme.of(context).dividerColor, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tu Cuota', style: _titleStyle(isDark, context)),
              Text(
                '\$${quota.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedActionCard(
    MatchEntity match,
    bool isDark,
    bool isAnyCaptain,
    int? currentUserId,
  ) {
    if (!isAnyCaptain) {
      return _buildCard(
        isDark,
        child: Column(
          children: [
            const Icon(Icons.shield, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              '¡Alineaciones Confirmadas!',
              style: _titleStyle(isDark, context),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prepárate para el encuentro. Los capitanes registrarán el resultado final.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Lógica para Capitanes
    final hasMatchPassed = DateTime.now().isAfter(match.fechaInicioEstimada);
    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final myGoles = isCaptainA
        ? match.resultadoGolesACapA
        : match.resultadoGolesBCapB;
    final hasRegistered = myGoles != null;

    if (!hasMatchPassed) {
      return _buildCard(
        isDark,
        child: Column(
          children: [
            const Icon(Icons.timer, color: Colors.orange, size: 32),
            const SizedBox(height: 12),
            Text('Esperando el Partido', style: _titleStyle(isDark, context)),
            const SizedBox(height: 8),
            const Text(
              'Una vez que finalice el partido, podrás registrar el resultado aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_score, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Registro de Resultado',
                style: _titleStyle(isDark, context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasRegistered
                ? 'Ya has registrado tu versión del resultado. Esperando confirmación del rival.'
                : 'El partido ya ha ocurrido. Es momento de registrar el marcador final.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (hasRegistered) {
                  context.push('/confirm-result', extra: {'matchEntity': match});
                } else {
                  context.push('/register-result', extra: {'matchEntity': match});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasRegistered
                    ? Colors.grey[800]
                    : AppColors.primary,
                foregroundColor: hasRegistered ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                hasRegistered
                    ? 'Ver Resultado Registrado'
                    : 'Registrar Resultado',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    MatchEntity match,
    bool isDark,
    bool isOrganizer,
    bool isAnyCaptain,
    MatchRole role,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si está publicada y es el organizador, mostrar botones de gestión
    if (match.estatus == 'publicada' && isOrganizer) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/crear-partido', extra: match);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Datos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleCancelMatch(match.id),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Si no es capitán y está publicada o negociando, no hay barra de acciones
    // EXCEPCIÓN: Si está publicada y soy externo, quiero ver el botón de Aceptar
    if (!isAnyCaptain &&
        (match.estatus == 'publicada' || match.estatus == 'negociando')) {
      if (!(match.estatus == 'publicada' && role == MatchRole.external)) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (isAnyCaptain)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleContactar(match),
                icon: const Icon(Icons.message_outlined),
                label: const Text('Contactar Rival'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (match.estatus == 'publicada' &&
              role == MatchRole.external &&
              match.idEquipoB == null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/accept-encounter', extra: {'match': match}),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Aceptar Encuentro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          if (isAnyCaptain) ...[
            if (match.estatus == 'negociando') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/configure-match',
                    extra: {'matchEntity': match},
                  ),
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text('Coordinar Encuentro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (match.estatus == 'pendiente_pago') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/match-dashboard',
                    extra: {'matchEntity': match},
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Gestionar Pagos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (match.estatus == 'confirmada') ...[
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  final hasMatchPassed = DateTime.now().isAfter(match.fechaInicioEstimada);
                  if (!hasMatchPassed) {
                    return Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(
                          '/match-dashboard',
                          extra: {'matchEntity': match},
                        ),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Gestionar Pagos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  }

                  final profileState = context.read<ProfileBloc>().state;
                  final currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;
                  final isCaptainA = currentUserId == match.idUsuarioOrg;
                  final myGoles = isCaptainA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
                  final hasRegistered = myGoles != null;

                  return Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (hasRegistered) {
                          context.push('/confirm-result', extra: {'matchEntity': match});
                        } else {
                          context.push('/register-result', extra: {'matchEntity': match});
                        }
                      },
                      icon: const Icon(Icons.sports_score_outlined),
                      label: Text(hasRegistered ? 'Ver Resultado' : 'Registrar Resultado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ] else if (match.estatus == 'completada') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/match-history'),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Ver Resultado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            if (match.estatus == 'completada') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/match-history'),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Ver Resultado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (match.estatus == 'pendiente_pago' ||
                match.estatus == 'confirmada') ...[
              const SizedBox(width: 12),
              Builder(
                builder: (context) {
                  final profileState = context.read<ProfileBloc>().state;
                  int? currentUserId;
                  if (profileState is ProfileLoaded) {
                    currentUserId = profileState.profile.id;
                  }

                  final me = _players
                      .where((p) => p.idUsuario == currentUserId)
                      .firstOrNull;
                  final hasReported =
                      me?.urlReciboPago != null && me!.urlReciboPago!.isNotEmpty;

                  return Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final amIInA =
                            _players.any(
                              (p) =>
                                  p.idUsuario == currentUserId &&
                                  p.idEquipo == match.idEquipoA,
                            ) ||
                            match.idUsuarioOrg == currentUserId;
                        final myName = amIInA
                            ? (match.nombreEquipoA ?? 'Tu Equipo')
                            : (match.nombreEquipoB ?? 'Tu Equipo');
                        final myLogo = amIInA
                            ? match.logoEquipoA
                            : match.logoEquipoB;

                        final isVerified = me?.estatusPago == 'verificado';

                        if (isVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tu pago ya ha sido verificado'),
                            ),
                          );
                          return;
                        }

                        final payment = PaymentEntity(
                          idPartida: match.id,
                          teamName: myName,
                          teamLogo: myLogo,
                          concepto: match.sportName ?? 'Partido',
                          monto: match.cuotaPorJugador,
                          isPaid: false,
                          estatusPago: me?.estatusPago ?? 'pendiente',
                          banco: amIInA ? match.bancoReceptor : match.bancoCapitanB,
                          cedula: amIInA
                              ? match.cedulaReceptora
                              : match.cedulaCapitanB,
                          telefono: amIInA
                              ? match.telefonoReceptor
                              : match.telefonoCapitanBPago,
                        );

                        context.push(
                          '/upload-receipt',
                          extra: {'payment': payment},
                        );
                      },
                      icon: Icon(
                        hasReported
                            ? Icons.edit_note_outlined
                            : Icons.account_balance_wallet_outlined,
                      ),
                      label: Text(hasReported ? 'Modificar Pago' : 'Ir a Pagar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(
    MatchEntity match,
    bool isDark,
    int? currentUserId,
  ) {
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    final isTeamA = currentUserId == match.idUsuarioOrg;
    final myGoles = isTeamA ? golesA : golesB;
    final rivalGoles = isTeamA ? golesB : golesA;

    return _buildOfficialScoreCard(
      myGoles,
      rivalGoles,
      isTeamA
          ? (match.nombreEquipoA ?? 'Mi Equipo')
          : (match.nombreEquipoB ?? 'Mi Equipo'),
      isDark,
    );
  }

  Widget _buildOfficialScoreCard(int f, int c, String teamName, bool isDark) {
    final style = _getResultStyle(f, c);
    final Color mainColor = style['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.15),
            mainColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mainColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style['icon'] as IconData, color: mainColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  style['label'] as String,
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildScoreDigit(f, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: mainColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              _buildScoreDigit(c, isDark),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            f > c
                ? '¡Gran Victoria!'
                : (f < c ? 'A seguir mejorando' : 'Partido reñido'),
            style: TextStyle(
              color: mainColor,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark) {
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, dynamic> _getResultStyle(int f, int c) {
    if (f > c) {
      return {
        'label': 'VICTORIA',
        'color': Colors.greenAccent,
        'icon': Icons.emoji_events,
      };
    } else if (f < c) {
      return {
        'label': 'DERROTA',
        'color': Colors.redAccent,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'label': 'EMPATE',
        'color': Colors.amberAccent,
        'icon': Icons.drag_handle,
      };
    }
  }

  Widget _buildPlayersSection(bool isDark, MatchEntity match) {
    if (_isLoadingPlayers) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_players.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Alineaciones Confirmadas',
            style: _titleStyle(isDark, context),
          ),
        ),
        const SizedBox(height: 12),
        _buildTeamLineup(
          match.nombreEquipoA ?? 'Equipo A',
          _players.where((p) => p.idEquipo == match.idEquipoA).toList(),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildTeamLineup(
          match.nombreEquipoB ?? 'Equipo B',
          _players.where((p) => p.idEquipo == match.idEquipoB).toList(),
          isDark,
        ),
      ],
    );
  }

  Widget _buildTeamLineup(
    String teamName,
    List<MatchPlayer> players,
    bool isDark,
  ) {
    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                teamName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${players.length} Jugadores',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (players.isEmpty)
            const Center(
              child: Text(
                'Sin jugadores registrados',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: players
                  .map((p) => _buildPlayerChip(p, isDark))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(MatchPlayer p, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage:
                (p.urlFotoPerfil != null && p.urlFotoPerfil!.startsWith('http'))
                ? NetworkImage(p.urlFotoPerfil!)
                : null,
            child:
                (p.urlFotoPerfil == null ||
                    !p.urlFotoPerfil!.startsWith('http'))
                ? const Icon(Icons.person, size: 10, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            p.nombreUsuario,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(bool isDark, BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  Widget _buildPaymentsStatusCard(
    BuildContext context,
    MatchEntity match,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    final profileState = context.read<ProfileBloc>().state;
    int? myTeamId;
    int? rivalTeamId;
    if (profileState is ProfileLoaded) {
      final myId = profileState.profile.id;
      final amIInA =
          _players.any(
            (p) => p.idUsuario == myId && p.idEquipo == match.idEquipoA,
          ) ||
          match.idUsuarioOrg == myId;
      myTeamId = amIInA ? match.idEquipoA : match.idEquipoB;
      rivalTeamId = amIInA ? match.idEquipoB : match.idEquipoA;
    }

    final myTeamPlayers = _players
        .where((p) => p.idEquipo == myTeamId)
        .toList();
    final myPaidCount = myTeamPlayers
        .where((p) => p.estatusPago == 'verificado')
        .length;
    final myTotalCount = myTeamPlayers.length;

    final rivalTeamPlayers = _players
        .where((p) => p.idEquipo == rivalTeamId)
        .toList();
    final rivalPaidCount = rivalTeamPlayers
        .where((p) => p.estatusPago == 'verificado')
        .length;
    final rivalTotalCount = rivalTeamPlayers.length;

    final quota = match.cuotaPorJugador;

    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estado de Pagos', style: _titleStyle(isDark, context)),
              if (!_isLoadingPlayers)
                Text(
                  'Cuota: \$${quota.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTeamProgress(
            myTotalCount > 0 && myPaidCount >= myTotalCount
                ? '✓ Tu Equipo al día'
                : '⏳ Tu Equipo ($myPaidCount/$myTotalCount)',
            myPaidCount,
            myTotalCount,
            AppColors.primary,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTeamProgress(
            'Equipo Rival',
            rivalPaidCount,
            rivalTotalCount,
            Colors.cyan,
            theme,
          ),
          const SizedBox(height: 16),
          Text(
            'El partido se confirmará automáticamente cuando todos los jugadores hayan pagado.',
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamProgress(
    String label,
    int paid,
    int total,
    Color color,
    ThemeData theme,
  ) {
    final progress = total > 0 ? paid / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              '$paid de $total',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
}

class PositionDetector extends StatelessWidget {
  final VoidCallback onTap;
  const PositionDetector({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
