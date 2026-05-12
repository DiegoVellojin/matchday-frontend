import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';
import '../../../domain/entities/match_status.dart';

class MatchStatusCard extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final bool isOrganizer;

  const MatchStatusCard({
    super.key,
    required this.match,
    required this.isDark,
    required this.isOrganizer,
  });

  @override
  Widget build(BuildContext context) {
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
      statusDesc = "Los términos fueron aceptados. Realiza tu pago para confirmar.";
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
}
