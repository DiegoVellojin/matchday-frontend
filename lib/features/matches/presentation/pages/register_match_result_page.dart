import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';

class RegisterMatchResultPage extends StatefulWidget {
  final MatchEntity partido;

  const RegisterMatchResultPage({super.key, required this.partido});

  @override
  State<RegisterMatchResultPage> createState() => _RegisterMatchResultPageState();
}

class _RegisterMatchResultPageState extends State<RegisterMatchResultPage> {
  int _golesFavor = 0;
  int _golesContra = 0;

  Map<String, dynamic> _calcularResultado(ThemeData theme) {
    if (_golesFavor > _golesContra) {
      return {'texto': 'Victoria', 'puntos': 3, 'color': theme.colorScheme.primary, 'icon': Icons.trending_up};
    }
    if (_golesFavor < _golesContra) {
      return {'texto': 'Derrota', 'puntos': 0, 'color': theme.colorScheme.error, 'icon': Icons.trending_down};
    }
    return {'texto': 'Empate', 'puntos': 1, 'color': Colors.amber, 'icon': Icons.remove};
  }

  void _handleSubmit(BuildContext context) {
    context.read<MatchesBloc>().add(
      RegisterResultEvent(
        matchId: widget.partido.id,
        golesA: _golesFavor, // Asumiendo que el usuario es equipo A
        golesB: _golesContra,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultado = _calcularResultado(theme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar Resultado', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('Como Organizador', style: theme.textTheme.bodySmall),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor, height: 1.0),
        ),
      ),
      body: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchResultRegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resultado registrado exitosamente', style: TextStyle(color: theme.colorScheme.onPrimary)),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.colorScheme.onError)), backgroundColor: theme.colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Información del Partido
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: theme.dividerColor, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: ClipOval(
                                  child: (widget.partido.logoEquipoA != null && widget.partido.logoEquipoA!.startsWith('http'))
                                      ? Image.network(
                                          widget.partido.logoEquipoA!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) => const Text('⚽', style: TextStyle(fontSize: 24)),
                                        )
                                      : const Text('⚽', style: TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.partido.nombreEquipoA ?? 'Mi Equipo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Tu Equipo', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                                ],
                              ),
                            ],
                          ),
                          Text('VS', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Rival FC', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Rival', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: theme.dividerColor, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: ClipOval(
                                  child: (widget.partido.logoEquipoB != null && widget.partido.logoEquipoB!.startsWith('http'))
                                      ? Image.network(
                                          widget.partido.logoEquipoB!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) => const Text('⚽', style: TextStyle(fontSize: 24)),
                                        )
                                      : const Text('⚽', style: TextStyle(fontSize: 24)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Fecha', style: theme.textTheme.bodySmall),
                              Text('Sábado, 26 Abril 2026', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Ubicación', style: theme.textTheme.bodySmall),
                              Text(widget.partido.nombreCancha ?? 'Cancha', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Marcador
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Ingresa el Marcador Final', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCounter(context, 'Goles a Favor', _golesFavor, true, (val) => setState(() => _golesFavor = val)),
                          _buildCounter(context, 'Goles en Contra', _golesContra, false, (val) => setState(() => _golesContra = val)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Marcador Final', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text('$_golesFavor - $_golesContra', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Resultado Calculado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (resultado['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (resultado['color'] as Color).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(resultado['icon'] as IconData, size: 32, color: resultado['color'] as Color),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Resultado', style: theme.textTheme.bodySmall),
                              Text(resultado['texto'] as String, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: resultado['color'] as Color)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Puntos', style: theme.textTheme.bodySmall),
                          Text('${resultado['puntos']}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: resultado['color'] as Color)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Información
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importante', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('• El organizador del otro equipo también debe registrar el resultado', style: theme.textTheme.bodySmall),
                      Text('• Los resultados serán comparados para verificar coincidencia', style: theme.textTheme.bodySmall),
                      Text('• Si hay discrepancia, se solicitará revisión manual', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Botón Confirmar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirmar Resultado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounter(BuildContext context, String label, int value, bool isFavor, Function(int) onChanged) {
    final theme = Theme.of(context);
    final color = isFavor ? theme.colorScheme.primary : theme.colorScheme.error;
    
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: isFavor ? theme.colorScheme.onPrimary : Colors.white,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text('$value', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: () => onChanged(value > 0 ? value - 1 : 0),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: theme.dividerColor,
            foregroundColor: theme.textTheme.bodyLarge?.color,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
