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
    final myGolesFavor = isTeamA
        ? match.resultadoGolesACapA
        : match.resultadoGolesBCapB;
    final myGolesContra = isTeamA
        ? match.resultadoGolesBCapA
        : match.resultadoGolesACapB;

    // Resultados del rival
    final rivalGolesFavor = isTeamA
        ? match.resultadoGolesBCapB
        : match.resultadoGolesACapA;
    final rivalGolesContra = isTeamA
        ? match.resultadoGolesACapB
        : match.resultadoGolesBCapA;

    final hasRivalRegistered =
        rivalGolesFavor != null && rivalGolesContra != null;

    // Verificar si coinciden
    final resultadosCoinciden =
        hasRivalRegistered &&
        myGolesFavor == rivalGolesContra &&
        myGolesContra == rivalGolesFavor;

    final myTeamName = isTeamA
        ? (match.nombreEquipoA ?? 'Mi Equipo')
        : (match.nombreEquipoB ?? 'Mi Equipo');
    final opponentName = isTeamA
        ? (match.nombreEquipoB ?? 'Rival')
        : (match.nombreEquipoA ?? 'Rival');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner de Estado
                  _buildStatusBanner(
                        hasRivalRegistered,
                        resultadosCoinciden,
                        isDark,
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 32),

                  // Comparación Detallada
                  _buildComparisonSection(
                    isDark,
                    colorScheme,
                    myTeamName,
                    opponentName,
                    myGolesFavor,
                    myGolesContra,
                    rivalGolesFavor,
                    rivalGolesContra,
                    theme,
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  const SizedBox(height: 32),

                  // Marcador Oficial Final
                  if (resultadosCoinciden)
                    _buildOfficialScoreCard(
                          myGolesFavor!,
                          myGolesContra!,
                          myTeamName,
                          isDark,
                          theme,
                        )
                        .animate()
                        .scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                          delay: 400.ms,
                        )
                        .fadeIn()
                        .shimmer(
                          duration: 3.seconds,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),

                  const SizedBox(height: 100), // Espacio para el botón inferior
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        context,
        hasRivalRegistered,
        resultadosCoinciden,
        isDark,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Confirmación'.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        background: Container(color: colorScheme.surface),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildStatusBanner(
    bool hasRivalRegistered,
    bool resultadosCoinciden,
    bool isDark,
  ) {
    Color color;
    IconData icon;
    String title;
    String desc;

    if (!hasRivalRegistered) {
      color = Colors.orangeAccent;
      icon = Icons.hourglass_empty_rounded;
      title = 'Esperando al Rival';
      desc =
          'Tu resultado ha sido enviado. El otro capitán aún no ha registrado su versión.';
    } else if (resultadosCoinciden) {
      color = AppColors.primary;
      icon = Icons.verified_rounded;
      title = '¡Resultados Verificados!';
      desc =
          'Ambas versiones coinciden perfectamente. El partido ha sido validado con éxito.';
    } else {
      color = Colors.redAccent;
      icon = Icons.report_problem_rounded;
      title = 'Discrepancia en el Marcador';
      desc =
          'Los resultados no coinciden. Por favor, comunícate con el otro capitán para acordar el resultado final.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    bool isDark,
    ColorScheme colorScheme,
    String myTeam,
    String opponent,
    int? myF,
    int? myC,
    int? rivF,
    int? rivC,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'COMPARACIÓN DETALLADA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? AppColors.border : theme.dividerColor,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            children: [
              _buildTeamResultRow(myTeam, 'Tu Reporte', myF, myC, true, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: theme.dividerColor, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: theme.dividerColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: theme.dividerColor, thickness: 1),
                    ),
                  ],
                ),
              ),
              _buildTeamResultRow(
                opponent,
                'Reporte Rival',
                rivF,
                rivC,
                false,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamResultRow(
    String name,
    String label,
    int? f,
    int? c,
    bool isMe,
    bool isDark,
  ) {
    final hasData = f != null && c != null;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.primary.withValues(alpha: 0.1)
                : (isDark ? Colors.white10 : Colors.grey[100]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              isMe ? '👤' : '🛡️',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isMe ? AppColors.primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (hasData)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : (isDark ? Colors.white10 : Colors.grey[100]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$f - $c',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isMe
                    ? AppColors.primary
                    : (isDark ? Colors.white : Colors.black),
                letterSpacing: 1,
              ),
            ),
          )
        else
          Text(
            'PENDIENTE',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildOfficialScoreCard(
    int f,
    int c,
    String teamName,
    bool isDark,
    ThemeData theme,
  ) {
    final style = _getResultStyle(f, c);
    final Color mainColor = style['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: mainColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'MARCADOR OFICIAL'.toUpperCase(),
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreDigit(f, isDark, mainColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: mainColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              _buildScoreDigit(c, isDark, mainColor),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            teamName.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              style['label'] as String,
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDigit(int value, bool isDark, Color mainColor) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : Colors.black,
        ),
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

  Widget _buildBottomBar(
    BuildContext context,
    bool hasRivalRegistered,
    bool resultadosCoinciden,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: _buildMainButton(
          context,
          hasRivalRegistered,
          resultadosCoinciden,
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    bool hasRivalRegistered,
    bool resultadosCoinciden,
  ) {
    if (!hasRivalRegistered) {
      return _actionButton(
        onPressed: () => Navigator.of(context).pop(),
        label: 'Volver al Dashboard',
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
      );
    }

    if (resultadosCoinciden) {
      return _actionButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        label: 'Finalizar Encuentro',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
      );
    } else {
      return _actionButton(
        onPressed: () => Navigator.of(context).pop(),
        label: 'Corregir Marcador',
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      );
    }
  }

  Widget _actionButton({
    required VoidCallback onPressed,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}
