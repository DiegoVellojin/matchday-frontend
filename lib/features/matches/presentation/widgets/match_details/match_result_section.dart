import 'package:flutter/material.dart';
import '../../../domain/entities/match_entity.dart';

class MatchResultSection extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;
  final int? currentUserId;

  const MatchResultSection({
    super.key,
    required this.match,
    required this.isDark,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final golesA = match.resultadoGolesACapA ?? match.resultadoGolesACapB ?? 0;
    final golesB = match.resultadoGolesBCapA ?? match.resultadoGolesBCapB ?? 0;

    final isTeamA = currentUserId == match.idUsuarioOrg;
    final myGoles = isTeamA ? golesA : golesB;
    final rivalGoles = isTeamA ? golesB : golesA;

    final style = _getResultStyle(myGoles, rivalGoles);
    final Color mainColor = style['color'] as Color;
    final teamName = isTeamA ? (match.nombreEquipoA ?? 'Mi Equipo') : (match.nombreEquipoB ?? 'Mi Equipo');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mainColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style['icon'] as IconData, color: mainColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  (style['label'] as String).toUpperCase(),
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildScoreDigit(myGoles, isDark, mainColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
              ),
              _buildScoreDigit(rivalGoles, isDark, mainColor),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            teamName.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            myGoles > rivalGoles
                ? '¡GRAN VICTORIA!'
                : (myGoles < rivalGoles ? 'A SEGUIR MEJORANDO' : 'PARTIDO REÑIDO'),
            style: TextStyle(
              color: mainColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark, Color color) {
    return Container(
      width: 75,
      height: 95,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 52, 
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : Colors.black,
          letterSpacing: -2,
        ),
      ),
    );
  }

  Map<String, dynamic> _getResultStyle(int f, int c) {
    if (f > c) {
      return {
        'label': 'Victoria',
        'color': Colors.greenAccent,
        'icon': Icons.emoji_events_rounded,
      };
    } else if (f < c) {
      return {
        'label': 'Derrota',
        'color': Colors.redAccent,
        'icon': Icons.trending_down_rounded,
      };
    } else {
      return {
        'label': 'Empate',
        'color': Colors.amberAccent,
        'icon': Icons.drag_handle_rounded,
      };
    }
  }
}
