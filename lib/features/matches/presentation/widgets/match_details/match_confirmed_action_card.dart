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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text('¡Alineaciones Confirmadas!', style: _titleStyle(context)),
            const SizedBox(height: 8),
            Text(
              'Prepárate para el encuentro. Los capitanes registrarán el resultado final.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final hasMatchPassed = DateTime.now().toUtc().isAfter(match.fechaInicioEstimada.toUtc());
    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final myGoles = isCaptainA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
    final hasRegistered = myGoles != null;

    if (!hasMatchPassed) {
      return _buildCard(
        context,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_rounded, color: Colors.orange, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Esperando el Partido', style: _titleStyle(context)),
            const SizedBox(height: 8),
            Text(
              'Una vez que finalice el partido, podrás registrar el resultado aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_score_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Registro de Resultado', style: _titleStyle(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasRegistered
                ? 'Ya has registrado tu versión del resultado. Esperando confirmación del rival.'
                : 'El partido ya ha ocurrido. Es momento de registrar el marcador final.',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54, 
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                if (hasRegistered) {
                  context.push('/confirm-result', extra: {'matchEntity': match});
                } else {
                  context.push('/register-result', extra: {'matchEntity': match});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasRegistered ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)) : AppColors.primary,
                foregroundColor: hasRegistered ? (isDark ? Colors.white : Colors.black) : Colors.black,
                elevation: hasRegistered ? 0 : 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                hasRegistered ? 'VER RESULTADO' : 'REGISTRAR RESULTADO',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
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
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      );
}
