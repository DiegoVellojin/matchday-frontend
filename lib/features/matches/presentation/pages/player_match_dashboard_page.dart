import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';

class PlayerMatchDashboardPage extends StatelessWidget {
  final MatchEntity match;

  const PlayerMatchDashboardPage({super.key, required this.match});

  void _openGoogleMaps() async {
    // Por ahora usamos una búsqueda genérica si no tenemos coordenadas
    final query = Uri.encodeComponent(match.nombreCancha ?? 'Cancha de fútbol');
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

    return Scaffold(
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
            // Card de Equipos
            _buildTeamsCard(context, isDark),
            const SizedBox(height: 20),

            // Info del Partido (Fecha, Cancha, Mapa)
            _buildMatchInfoCard(context, isDark),
            const SizedBox(height: 20),

            // Estado de Pagos (Vista Jugador)
            _buildPaymentsStatusCard(context, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildTeamsCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
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
              _teamAvatar(context, match.logoEquipoA, 'A'),
              const Spacer(),
              const Text('VS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
              const Spacer(),
              _teamAvatar(context, match.logoEquipoB, 'B'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.nombreEquipoA ?? 'Equipo A',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  match.nombreEquipoB ?? 'Tu Equipo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
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
        child: url != null && url.isNotEmpty
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
          _infoRow(context, Icons.calendar_today, 'Fecha', DateFormat('EEEE d MMMM', 'es_VE').format(match.fechaInicioEstimada), isDark),
          Divider(color: theme.dividerColor, height: 24),
          _infoRow(context, Icons.access_time, 'Hora', '${DateFormat('jm').format(match.fechaInicioEstimada)} - ${DateFormat('jm').format(match.fechaFinEstimada)}', isDark),
          Divider(color: theme.dividerColor, height: 24),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(match.nombreCancha ?? 'Cancha por definir', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentsStatusCard(BuildContext context, bool isDark) {
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
          Text('Estado del Equipo', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Text(
            'El seguimiento detallado de pagos de tus compañeros estará disponible una vez que todos confirmen.',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            'El partido se confirmará cuando todos los jugadores realicen su pago.',
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }



  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
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
            onPressed: () {
              // Navegar a subir comprobante
              // context.push('/upload-receipt', extra: {'match': match});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Realizar Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
