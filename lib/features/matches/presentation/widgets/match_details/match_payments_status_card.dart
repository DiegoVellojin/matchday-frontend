import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

class MatchPaymentsStatusCard extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final int myTeamId;
  final int rivalTeamId;
  final int myPaidCount;
  final int myTotalCount;
  final int rivalPaidCount;
  final int rivalTotalCount;

  const MatchPaymentsStatusCard({
    super.key,
    required this.match,
    required this.isDark,
    required this.myTeamId,
    required this.rivalTeamId,
    required this.myPaidCount,
    required this.myTotalCount,
    required this.rivalPaidCount,
    required this.rivalTotalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    final quota = match.cuotaPorJugador;

    return _buildCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estado de Pagos', style: _titleStyle(context)),
              Text(
                'Cuota: ${match.currentSymbol}${quota.toStringAsFixed(2)}',
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
            myTotalCount > 0 && myPaidCount >= myTotalCount ? '✓ Tu Equipo al día' : '⏳ Tu Equipo ($myPaidCount/$myTotalCount)',
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

  Widget _buildTeamProgress(String label, int paid, int total, Color color, ThemeData theme) {
    final progress = total > 0 ? paid / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(
              '$paid de $total',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
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
