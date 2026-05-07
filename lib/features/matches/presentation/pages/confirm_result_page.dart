import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';

class ConfirmarResultadoPage extends StatelessWidget {
  final MatchEntity match;
  final int currentUserId;

  const ConfirmarResultadoPage({
    super.key,
    required this.match,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isTeamA = match.idUsuarioOrg == currentUserId;
    
    // Nuestros resultados registrados
    final myGolesFavor = isTeamA ? match.resultadoGolesACapA : match.resultadoGolesBCapB;
    final myGolesContra = isTeamA ? match.resultadoGolesBCapA : match.resultadoGolesACapB;
    
    // Resultados del rival
    final rivalGolesFavor = isTeamA ? match.resultadoGolesBCapB : match.resultadoGolesACapA;
    final rivalGolesContra = isTeamA ? match.resultadoGolesACapB : match.resultadoGolesBCapA;

    final hasRivalRegistered = rivalGolesFavor != null && rivalGolesContra != null;
    
    // Verificar si coinciden (desde nuestra perspectiva)
    // Mi favor == Su contra AND Mi contra == Su favor
    final resultadosCoinciden = hasRivalRegistered && 
                                myGolesFavor == rivalGolesContra && 
                                myGolesContra == rivalGolesFavor;

    final myTeamName = isTeamA ? (match.nombreEquipoA ?? 'Mi Equipo') : (match.nombreEquipoB ?? 'Mi Equipo');
    final opponentName = isTeamA ? (match.nombreEquipoB ?? 'Rival') : (match.nombreEquipoA ?? 'Rival');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Confirmación de Resultado',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado de Registro
            _buildStatusBanner(hasRivalRegistered, resultadosCoinciden, isDark)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // Comparación de Resultados
            _buildComparisonCard(isDark, colorScheme, myTeamName, opponentName, myGolesFavor, myGolesContra, rivalGolesFavor, rivalGolesContra, theme),
            const SizedBox(height: 24),

            // Marcador Oficial Confirmado (Solo si coinciden)
            if (resultadosCoinciden)
              _buildOfficialScoreCard(myGolesFavor!, myGolesContra!, myTeamName, isDark, theme)
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn()
                .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.1)),

            const SizedBox(height: 24),

            // Botones de Acción
            _buildActionButtons(context, hasRivalRegistered, resultadosCoinciden),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(bool hasRivalRegistered, bool resultadosCoinciden, bool isDark) {
    if (!hasRivalRegistered) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.orangeAccent),
                SizedBox(width: 12),
                Text('Esperando Confirmación', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Tu resultado ha sido registrado. Esperando que el organizador del otro equipo registre su resultado.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final Color color = resultadosCoinciden ? AppColors.primary : Colors.redAccent;
    final IconData icon = resultadosCoinciden ? Icons.check_circle : Icons.warning_amber_rounded;
    final String title = resultadosCoinciden ? '¡Resultados Coinciden!' : 'Discrepancia Detectada';
    final String desc = resultadosCoinciden 
        ? 'Ambos equipos registraron el mismo resultado. El partido puede ser finalizado.'
        : 'Los resultados registrados no coinciden. Por favor vuelve a ingresar el marcador.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    bool isDark, 
    ColorScheme colorScheme, 
    String myTeam, 
    String opponent, 
    int? myF, int? myC, 
    int? rivF, int? rivC,
    ThemeData theme
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.border : theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Comparación de Resultados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Mi Resultado
          _buildTeamResultRow(myTeam, 'Tu Equipo', myF, myC, true, isDark),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: isDark ? AppColors.border : theme.dividerColor),
          ),
          
          // Resultado Rival
          _buildTeamResultRow(opponent, 'Equipo Rival', rivF, rivC, false, isDark),
        ],
      ),
    );
  }

  Widget _buildTeamResultRow(String name, String role, int? f, int? c, bool isMe, bool isDark) {
    final hasData = f != null && c != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: isDark ? AppColors.border : Colors.grey[200], child: const Text('⚽')),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(role, style: TextStyle(color: isMe ? AppColors.primary : AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
        if (hasData)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$f - $c', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColors.primary : (isDark ? Colors.white : Colors.black),
                )
              ),
              Text(isMe ? 'Registrado por ti' : 'Registrado por ellos', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          )
        else
          const Text('Pendiente', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildOfficialScoreCard(int f, int c, String teamName, bool isDark, ThemeData theme) {
    final style = _getResultStyle(f, c);
    final Color mainColor = style['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withValues(alpha: 0.15),
            mainColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mainColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style['icon'] as IconData, color: mainColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  style['label'] as String,
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildScoreDigit(f, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('-', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: mainColor.withValues(alpha: 0.5))),
              ),
              _buildScoreDigit(c, isDark),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            teamName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            f > c ? '¡Gran Victoria!' : (f < c ? 'A seguir mejorando' : 'Partido reñido'),
            style: TextStyle(color: mainColor, fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark) {
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, dynamic> _getResultStyle(int f, int c) {
    if (f > c) {
      return {
        'label': 'VICTORIA',
        'color': Colors.greenAccent,
        'icon': Icons.emoji_events,
      };
    } else if (f < c) {
      return {
        'label': 'DERROTA',
        'color': Colors.redAccent,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'label': 'EMPATE',
        'color': Colors.amberAccent,
        'icon': Icons.drag_handle,
      };
    }
  }

  Widget _buildActionButtons(BuildContext context, bool hasRivalRegistered, bool resultadosCoinciden) {
    if (!hasRivalRegistered) {
      return ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Volver al Dashboard'),
      );
    }

    if (resultadosCoinciden) {
      return ElevatedButton(
        onPressed: () {
          // El backend ya lo marca como completada automáticamente cuando coinciden.
          // Solo notificamos y volvemos.
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Finalizar y Guardar en Historial', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), // Vuelve a la pantalla de registro
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Volver a Registrar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
  }
}
