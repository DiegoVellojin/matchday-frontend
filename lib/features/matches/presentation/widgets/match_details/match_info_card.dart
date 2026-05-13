import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';
import '../../../../../core/widgets/matchday_marquee.dart';

class MatchInfoCard extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;

  const MatchInfoCard({
    super.key,
    required this.match,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildTeamAvatar(match.logoEquipoA, 64, context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MatchDayMarquee(
                      text: match.nombreEquipoA?.toUpperCase() ?? 'EQUIPO CAPITÁN',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ORGANIZADO POR ${match.nombreCapitanA?.toUpperCase() ?? 'CAPI'}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.sportName?.toUpperCase() ?? 'FÚTBOL',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 24),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            DateFormat("EEEE, d 'de' MMMM • hh:mm a", 'es_VE').format(match.fechaInicioEstimada.toLocal()),
            context,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.location_on_rounded,
            match.nombreCancha ?? 'Ubicación pendiente de confirmar',
            context,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            match.moneda == 'EUR' ? Icons.euro_rounded : Icons.attach_money_rounded,
            'PRESUPUESTO: ${match.currentSymbol}${match.costoTotal}',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAvatar(String? url, double size, BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: ClipOval(
        child: (url != null && url.startsWith('http'))
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => const Icon(Icons.sports_soccer_rounded, size: 32, color: AppColors.primary),
              )
            : const Icon(Icons.sports_soccer_rounded, size: 32, color: AppColors.primary),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: MatchDayMarquee(
            text: text,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
