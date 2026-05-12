import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

class MatchConfirmedActionCard extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final bool isAnyCaptain;
  final int? currentUserId;

  const MatchConfirmedActionCard({
    super.key,
    required this.match,
    required this.isDark,
    required this.isAnyCaptain,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAnyCaptain) {
      return _buildCard(
        context,
        child: Column(
          children: [
            const Icon(Icons.shield, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text('¡Alineaciones Confirmadas!', style: _titleStyle(context)),
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

    final hasMatchPassed = DateTime.now().isAfter(match.fechaInicioEstimada);
    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final myGoles = isCaptainA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
    final hasRegistered = myGoles != null;

    if (!hasMatchPassed) {
      return _buildCard(
        context,
        child: Column(
          children: [
            const Icon(Icons.timer, color: Colors.orange, size: 32),
            const SizedBox(height: 12),
            Text('Esperando el Partido', style: _titleStyle(context)),
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
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_score, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Registro de Resultado', style: _titleStyle(context)),
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
                backgroundColor: hasRegistered ? Colors.grey[800] : AppColors.primary,
                foregroundColor: hasRegistered ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                hasRegistered ? 'Ver Resultado Registrado' : 'Registrar Resultado',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
}
