import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

class MatchNegotiationCard extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final bool isAnyCaptain;

  const MatchNegotiationCard({
    super.key,
    required this.match,
    required this.isDark,
    required this.isAnyCaptain,
  });

  @override
  Widget build(BuildContext context) {
    final hasTerms = match.costoTotal > 0 && match.fechaAcordada != null;

    if (!isAnyCaptain && !hasTerms) {
      return _buildCard(
        context,
        child: Column(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.orange, size: 32),
            const SizedBox(height: 12),
            Text('En espera de capitanes', style: _titleStyle(context)),
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
    final coincide = propA && propB && match.propuestaCostoA == match.propuestaCostoB;

    return _buildCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (coincide ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  coincide ? Icons.check_circle_rounded : Icons.handshake_rounded,
                  color: coincide ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Estado de la Negociación', style: _titleStyle(context)),
            ],
          ),
          const SizedBox(height: 20),
          _buildProposalRow('Capitán A', match.propuestaCostoA, match.propuestaFechaA, match.symbolA, context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          _buildProposalRow('Capitán B (Rival)', match.propuestaCostoB, match.propuestaFechaB, match.symbolB, context),
          if (propA && propB && !coincide)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los montos o fechas no coinciden. Se requiere coordinar propuesta.',
                        style: TextStyle(
                          color: Colors.orange[300], 
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _titleStyle(BuildContext context) => TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      );

  Widget _buildProposalRow(String label, double? costo, DateTime? fecha, String symbol, BuildContext context) {
    final textMuted = isDark ? Colors.grey[400] : Colors.black54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (fecha != null)
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 10, color: textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM - HH:mm', 'es_VE').format(fecha.toLocal()),
                    style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
        Text(
          costo != null ? '$symbol${costo.toStringAsFixed(2)}' : 'Sin propuesta',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: costo != null 
                ? (isDark ? Colors.white : Colors.black) 
                : textMuted?.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
