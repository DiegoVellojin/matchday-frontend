import 'package:flutter/material.dart';
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
      statusTitle = isOrganizer ? "ESPERANDO RIVAL" : "PARTIDO DISPONIBLE";
      statusDesc = isOrganizer
          ? "Tu partido ha sido publicado. Pronto recibirás un reto de otro capitán."
          : "¡Reta a este equipo y lidera a tu equipo hacia la victoria!";
    } else if (match.status is NegotiatingStatus) {
      statusTitle = "EN NEGOCIACIÓN";
      statusDesc = "Los capitanes están afinando los detalles de fecha y sede.";
    } else if (match.status is PendingPaymentStatus) {
      statusTitle = "PAGO PENDIENTE";
      statusDesc = "Términos aceptados. Procede con el pago para asegurar tu cupo.";
    } else if (match.status is CompletedStatus) {
      statusTitle = "PARTIDO FINALIZADO";
      statusDesc = "El silbato ha sonado. Ya puedes consultar los resultados finales.";
    } else if (match.status is CancelledStatus) {
      statusTitle = "PARTIDO CANCELADO";
      statusDesc = "Este encuentro ya no se llevará a cabo.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              statusIcon,
              size: 80,
              color: statusColor.withValues(alpha: 0.05),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusDesc,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: isDark ? Colors.grey[400] : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
