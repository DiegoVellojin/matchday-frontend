import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';

class RegisterResultPage extends StatefulWidget {
  final MatchEntity match;
  final int currentUserId;

  const RegisterResultPage({
    super.key,
    required this.match,
    required this.currentUserId,
  });

  @override
  State<RegisterResultPage> createState() => _RegisterResultPageState();
}

class _RegisterResultPageState extends State<RegisterResultPage> {
  int _golesFavor = 0;
  int _golesContra = 0;

  Map<String, dynamic> _getCalculatedResult() {
    if (_golesFavor > _golesContra) {
      return {
        'texto': 'Victoria',
        'puntos': 3,
        'color': AppColors.primary,
        'icon': Icons.trending_up,
      };
    } else if (_golesFavor < _golesContra) {
      return {
        'texto': 'Derrota',
        'puntos': 0,
        'color': Colors.redAccent,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'texto': 'Empate',
        'puntos': 1,
        'color': Colors.orangeAccent,
        'icon': Icons.remove,
      };
    }
  }

  void _handleSubmit() {
    final isTeamA = widget.match.idUsuarioOrg == widget.currentUserId;
    
    // El backend espera golesA para el Equipo A y golesB para el Equipo B
    // Independientemente de quién reporte.
    context.read<MatchesBloc>().add(RegisterResultEvent(
      matchId: widget.match.id,
      golesA: isTeamA ? _golesFavor : _golesContra,
      golesB: isTeamA ? _golesContra : _golesFavor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final result = _getCalculatedResult();
    
    final isTeamA = widget.match.idUsuarioOrg == widget.currentUserId;
    final myTeamName = isTeamA ? (widget.match.nombreEquipoA ?? 'Mi Equipo') : (widget.match.nombreEquipoB ?? 'Mi Equipo');
    final opponentName = isTeamA ? (widget.match.nombreEquipoB ?? 'Rival') : (widget.match.nombreEquipoA ?? 'Rival');

    return BlocListener<MatchesBloc, MatchesState>(
      listener: (context, state) {
        if (state is MatchResultRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resultado registrado exitosamente.')),
          );
          // Volvemos al dashboard. El dashboard al reconstruirse detectará que ya hay resultado
          // y permitirá ir a la pantalla de confirmación si el usuario lo desea.
          Navigator.of(context).pop();
        } else if (state is MatchesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REGISTRAR RESULTADO',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'COMO CAPITÁN',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información del Partido
              _buildMatchInfoCard(isDark, colorScheme, myTeamName, opponentName, theme)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              
              // Marcador
              _buildScoreEntryCard(isDark, colorScheme, result['color'], theme)
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              const SizedBox(height: 24),
              
              // Resultado Calculado
              _buildResultPreviewCard(result)
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              
              // Información Importante
              _buildImportantInfoBox()
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms),
              const SizedBox(height: 32),
              
              // Botón de Confirmación
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'CONFIRMAR RESULTADO',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                  ),
                ),
              ).animate()
               .fadeIn(delay: 800.ms)
               .shimmer(delay: 2.seconds, duration: 1.5.seconds),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchInfoCard(bool isDark, ColorScheme colorScheme, String myTeam, String opponent, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSmallLogo(isTeamA: true),
                    const SizedBox(height: 12),
                    Text(
                      myTeam, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), 
                      textAlign: TextAlign.center, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const Text('TU EQUIPO', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildSmallLogo(isTeamA: false),
                    const SizedBox(height: 12),
                    Text(
                      opponent, 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), 
                      textAlign: TextAlign.center, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const Text('RIVAL', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('FECHA', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE, d MMM', 'es_VE').format(widget.match.fechaAcordada ?? widget.match.fechaInicioEstimada), 
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('UBICACIÓN', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      widget.match.nombreCancha ?? 'Sede Pendiente', 
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), 
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLogo({required bool isTeamA}) {
    final url = isTeamA ? widget.match.logoEquipoA : widget.match.logoEquipoB;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty && url != 'null')
            ? Image.network(url, fit: BoxFit.cover)
            : const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
      ),
    );
  }

  Widget _buildScoreEntryCard(bool isDark, ColorScheme colorScheme, Color accentColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'MARCADOR FINAL', 
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 16,
                  letterSpacing: -0.5,
                )
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreControl('GOLES A FAVOR', _golesFavor, AppColors.primary, (val) => setState(() => _golesFavor = val)),
              _buildScoreControl('GOLES EN CONTRA', _golesContra, Colors.redAccent, (val) => setState(() => _golesContra = val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreControl(String label, int value, Color color, Function(int) onChanged) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        _scoreButton(Icons.add, color, () => onChanged(value + 1)),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$value', 
            style: TextStyle(color: color, fontSize: 48, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 16),
        _scoreButton(Icons.remove, Colors.grey, value > 0 ? () => onChanged(value - 1) : null),
      ],
    );
  }

  Widget _scoreButton(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null ? color.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: onTap != null ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: onTap != null ? color : Colors.grey.withValues(alpha: 0.3), size: 24),
      ),
    );
  }

  Widget _buildResultPreviewCard(Map<String, dynamic> result) {
    final Color color = result['color'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(result['icon'], color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RESULTADO', style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  Text(
                    result['texto'].toUpperCase(), 
                    style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('PUNTOS', style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              Text(
                '${result['puntos']}', 
                style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w900)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportantInfoBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'NOTAS IMPORTANTES', 
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoBullet('El organizador del otro equipo también debe registrar el resultado'),
          _buildInfoBullet('Los resultados serán comparados para verificar coincidencia'),
          _buildInfoBullet('Si hay discrepancia, se solicitará revisión manual'),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }
}
