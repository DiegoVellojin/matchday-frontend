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
              Icon(
                coincide ? Icons.check_circle_outline : Icons.handshake_outlined,
                color: coincide ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text('Estado de la Negociación', style: _titleStyle(context)),
            ],
          ),
          const SizedBox(height: 16),
          _buildProposalRow('Capitán A', match.propuestaCostoA, match.propuestaFechaA, context),
          const SizedBox(height: 12),
          _buildProposalRow('Capitán B (Rival)', match.propuestaCostoB, match.propuestaFechaB, context),
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
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los montos o fechas no coinciden. Usa "Coordinar Encuentro" para ajustar tu propuesta.',
                        style: TextStyle(color: Colors.orange[300], fontSize: 12),
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

  TextStyle _titleStyle(BuildContext context) => TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  Widget _buildProposalRow(String label, double? costo, DateTime? fecha, BuildContext context) {
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
              costo != null ? '${match.currentSymbol}${costo.toStringAsFixed(2)}' : 'Sin propuesta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: costo != null ? theme.colorScheme.onSurface : textMuted.withValues(alpha: 0.5),
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
}
