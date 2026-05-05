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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles del Encuentro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Equipos
            _buildTeamsCard(isDark),
            const SizedBox(height: 20),

            // Info del Partido (Fecha, Cancha, Mapa)
            _buildMatchInfoCard(isDark),
            const SizedBox(height: 20),

            // Estado de Pagos (Vista Jugador)
            _buildPaymentsStatusCard(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildTeamsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _teamAvatar(match.logoEquipoA, 'A'),
              const Spacer(),
              const Text('VS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
              const Spacer(),
              _teamAvatar(match.logoEquipoB, 'B'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.nombreEquipoA ?? 'Equipo A',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  match.nombreEquipoB ?? 'Tu Equipo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamAvatar(String? url, String label) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Text(label, style: const TextStyle(fontSize: 24, color: Colors.white))),
              )
            : Center(child: Text(label, style: const TextStyle(fontSize: 24, color: Colors.white))),
      ),
    );
  }

  Widget _buildMatchInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.calendar_today, 'Fecha', DateFormat('EEEE d MMMM', 'es_VE').format(match.fechaInicioEstimada)),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          _infoRow(Icons.access_time, 'Hora', '${DateFormat('jm').format(match.fechaInicioEstimada)} - ${DateFormat('jm').format(match.fechaFinEstimada)}'),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(match.nombreCancha ?? 'Cancha por definir', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Text('Ver ubicación en el mapa', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentsStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado del Equipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _paymentProgressRow('Tus compañeros', 0.6), // Simulado
          const SizedBox(height: 12),
          const Text(
            'El partido se confirmará cuando todos los jugadores realicen su pago.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _paymentProgressRow(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFF2A2A2A),
          color: AppColors.primary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!)),
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
