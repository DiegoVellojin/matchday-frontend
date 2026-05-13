import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildTeamAvatar(match.logoEquipoA, 56, context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.nombreEquipoA ?? 'Equipo Capitán',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Organizado por ${match.nombreCapitanA ?? 'Capi'}',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.sportName ?? 'Fútbol',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            DateFormat('EEEE, d MMMM • hh:mm a').format(match.fechaInicioEstimada),
            context,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.location_on_rounded,
            match.nombreCancha ?? 'Ubicación pendiente',
            context,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            match.moneda == 'EUR' ? Icons.euro_rounded : Icons.attach_money_rounded,
            'Costo estimado: ${match.moneda == 'EUR' ? '€' : '\$'}${match.costoTotal}',
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
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: ClipOval(
        child: (url != null && url.startsWith('http'))
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => const Icon(Icons.sports_soccer, size: 28),
              )
            : const Icon(Icons.sports_soccer, size: 28),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
