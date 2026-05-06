import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;
  const MatchDetailsPage({super.key, required this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

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
    final isOrganizer = currentUserId == match.idUsuarioOrg;

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
                  _buildMainStatusCard(match, isDark, isOrganizer),
                  const SizedBox(height: 16),
                  _buildMapPreview(match, isDark),
                  const SizedBox(height: 16),
                  _buildMatchInfoCard(match, isDark),
                  const SizedBox(height: 16),
                  if (match.estatus == 'negociando')
                    _buildNegotiationCard(context, match, isDark),
                  if (match.estatus == 'pendiente_pago')
                    _buildFinancialCard(match, isDark),
                  const SizedBox(height: 80), // Espacio para el bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, match, isDark, isOrganizer),
    );
  }

  Widget _buildSliverAppBar(MatchEntity match, bool isDark, bool isOrganizer) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Partido #${match.id}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
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
    if (name.contains('futbol') || name.contains('fútbol') || name.contains('soccer')) {
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
    if (name.contains('padel') || name.contains('pádel') || name.contains('pickleball')) {
      return 'https://images.unsplash.com/photo-1657704358775-ed705c7388d2?q=80&w=1000';
    }
    // Béisbol / Softbol
    if (name.contains('beisbol') || name.contains('béisbol') || name.contains('softbol') || name.contains('baseball')) {
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
    String statusTitle = "";
    String statusDesc = "";
    IconData statusIcon = Icons.info;
    Color statusColor = AppColors.primary;

    switch (match.estatus) {
      case 'publicada':
        statusTitle = isOrganizer ? "Esperando Oponente" : "Partido Disponible";
        statusDesc = isOrganizer
            ? "Tu partido ha sido publicado. Pronto un capitán te retará."
            : "¡Reta a este equipo y organiza el encuentro!";
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.blue;
        break;
      case 'negociando':
        statusTitle = "En Negociación";
        statusDesc = "Coordinando fecha y costos finales entre capitanes.";
        statusIcon = Icons.handshake;
        statusColor = Colors.orange;
        break;
      case 'pendiente_pago':
        statusTitle = "Pendiente de Pago";
        statusDesc =
            "Los términos fueron aceptados. Realiza tu pago para confirmar.";
        statusIcon = Icons.payments_outlined;
        statusColor = Colors.green;
        break;
      default:
        statusTitle = match.estatus.toUpperCase();
        statusDesc = "Sigue el proceso del partido.";
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
  ) {
    return _buildCard(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Propuesta de Términos',
                style: _titleStyle(isDark, context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNegotiationField(
            'Costo por Jugador / Total',
            _costController,
            Icons.attach_money,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildNegotiationField(
            'Fecha y Hora Sugerida',
            _dateController,
            Icons.calendar_today,
            isDark,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                  _dateController.text = DateFormat('dd/MM/yyyy').format(date);
                });
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.read<MatchesBloc>().add(
                  ProposeTermsEvent(
                    matchId: match.id,
                    fecha: selectedDate,
                    costo: double.tryParse(_costController.text) ?? 0.0,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Enviar Propuesta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(MatchEntity match, bool isDark) {
    const totalPlayers = 22;
    final quota = match.costoTotal / totalPlayers;
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

  Widget _buildBottomBar(
    BuildContext context,
    MatchEntity match,
    bool isDark,
    bool isOrganizer,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
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
          if (match.estatus == 'pendiente_pago') ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pagos'),
                icon: const Icon(Icons.attach_money),
                label: const Text('Pagar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNegotiationField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: textMuted, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.surface : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ],
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

  TextStyle _titleStyle(bool isDark, BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
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
