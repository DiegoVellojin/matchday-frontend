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
    context.read<MatchesBloc>().add(RegisterResultEvent(
      matchId: widget.match.id,
      golesA: _golesFavor,
      golesB: _golesContra,
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
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Resultado',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Como Organizador',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: const Text(
                  'Confirmar y Enviar Resultado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.border : theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(radius: 24, backgroundColor: isDark ? AppColors.border : Colors.grey[200], child: const Text('⚽', style: TextStyle(fontSize: 24))),
                    const SizedBox(height: 8),
                    Text(myTeam, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Text('Tu Equipo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              ),
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(radius: 24, backgroundColor: isDark ? AppColors.border : Colors.grey[200], child: const Text('⚽', style: TextStyle(fontSize: 24))),
                    const SizedBox(height: 8),
                    Text(opponent, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Text('Rival', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: isDark ? AppColors.border : theme.dividerColor),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Fecha', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text(DateFormat('EEEE, d MMM', 'es_VE').format(widget.match.fechaAcordada ?? widget.match.fechaInicioEstimada), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Ubicación', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text(widget.match.nombreCancha ?? 'Campo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreEntryCard(bool isDark, ColorScheme colorScheme, Color accentColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.border : theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Ingresa el Marcador Final', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreControl('Goles a Favor', _golesFavor, AppColors.primary, (val) => setState(() => _golesFavor = val)),
              _buildScoreControl('Goles en Contra', _golesContra, Colors.redAccent, (val) => setState(() => _golesContra = val)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Marcador Final', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text('$_golesFavor - $_golesContra', style: TextStyle(color: colorScheme.onSurface, fontSize: 40, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(result['icon'], color: color, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(result['texto'], style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Puntos', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${result['puntos']}', style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportantInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Importante', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
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
