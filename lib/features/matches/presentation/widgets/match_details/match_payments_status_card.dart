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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cuota: ${match.currentSymbol}${quota.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTeamProgress(
            myTotalCount > 0 && myPaidCount >= myTotalCount ? '✓ Tu Equipo al día' : '⏳ Tu Equipo ($myPaidCount/$myTotalCount)',
            myPaidCount,
            myTotalCount,
            AppColors.primary,
            theme,
          ),
          const SizedBox(height: 20),
          _buildTeamProgress(
            'Equipo Rival',
            rivalPaidCount,
            rivalTotalCount,
            Colors.cyanAccent,
            theme,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El partido se confirmará cuando todos los cupos estén pagados.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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

  Widget _buildTeamProgress(String label, int paid, int total, Color color, ThemeData theme) {
    final progress = total > 0 ? paid / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(
              '$paid de $total',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                color: color,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
