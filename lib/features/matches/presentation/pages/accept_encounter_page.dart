import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/match_entity.dart';
import '../bloc/matches_bloc.dart';
import '../../../teams/presentation/bloc/my_teams_bloc.dart';
import '../../../teams/presentation/bloc/my_teams_state.dart';
import '../../../teams/domain/entities/team_entity.dart';

class AcceptEncounterPage extends StatefulWidget {
  final MatchEntity match;

  const AcceptEncounterPage({super.key, required this.match});

  @override
  State<AcceptEncounterPage> createState() => _AcceptEncounterPageState();
}

class _AcceptEncounterPageState extends State<AcceptEncounterPage> {
  TeamEntity? _selectedTeam;

  void _handleAccept(BuildContext context) {
    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un equipo para aceptar el reto'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<MatchesBloc>().add(
      AcceptEncounterEvent(
        matchId: widget.match.id,
        teamId: _selectedTeam!.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final match = widget.match;

    return BlocConsumer<MatchesBloc, MatchesState>(
      listener: (context, state) {
        if (state is MatchEncounterAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Reto aceptado! Ya puedes configurar el encuentro.'),
              backgroundColor: cs.primary,
            ),
          );
          context.go('/hub');
        } else if (state is MatchesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, matchState) {
        final isLoading = matchState is MatchesLoading;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: cs.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Aceptar Encuentro',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: theme.dividerColor, height: 1),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Info del equipo rival ──────────────────────────────
              _buildRivalCard(context, theme, cs, match),
              const SizedBox(height: 20),

              // ── Selector de equipo ──────────────────────────────────
              Text(
                'Selecciona tu equipo',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Solo se muestran equipos del mismo deporte (${match.sportName ?? "sin especificar"}) donde eres capitán.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              _buildTeamSelector(context, theme, cs, match),
              const SizedBox(height: 20),

              // ── Próximos pasos ─────────────────────────────────────
              _buildNextStepsCard(theme, cs),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, theme, cs, isLoading),
        );
      },
    );
  }

  Widget _buildRivalCard(BuildContext context, ThemeData theme, ColorScheme cs, MatchEntity match) {
    final logo = match.logoEquipoA;
    final hasLogo = logo != null && logo.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (match.idEquipoA != null) context.push('/team-dashboard/${match.idEquipoA}');
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withValues(alpha: 0.4), width: 2),
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? Image.network(logo, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => const Center(child: Text('⚽', style: TextStyle(fontSize: 28))))
                        : const Center(child: Text('⚽', style: TextStyle(fontSize: 28))),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (match.idEquipoA != null) context.push('/team-dashboard/${match.idEquipoA}');
                      },
                      child: Text(
                        match.nombreEquipoA ?? 'Equipo Rival',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.sports, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          match.sportName ?? 'Sin especificar',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Cap: ${match.nombreCapitanA ?? "Desconocido"}',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBox(theme, cs, Icons.location_on_outlined, match.nombreCancha ?? 'Cancha', 'Ubicación'),
              const SizedBox(width: 8),
              _statBox(theme, cs, Icons.attach_money, '\$${match.costoTotal.toStringAsFixed(0)}', 'Costo aprox.'),
            ],
          ),
          const SizedBox(height: 16),
          // Botón WhatsApp / contactar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final phone = match.telefonoCapitanA;
                if (phone == null || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay número de teléfono disponible para el capitán rival')),
                  );
                  return;
                }
                final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
                final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent("Hola, vi tu partido en MatchDay y quiero aceptar el reto!")}');
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Contactar Capitán Rival', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(ThemeData theme, ColorScheme cs, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector(BuildContext context, ThemeData theme, ColorScheme cs, MatchEntity match) {
    return BlocBuilder<MyTeamsBloc, MyTeamsState>(
      builder: (context, state) {
        if (state is MyTeamsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTeams = state is MyTeamsLoaded ? state.teams : <TeamEntity>[];

        // Filtrar: solo equipos donde soy capitán y el deporte coincide
        final profileSportId = match.idDeporte;
        final eligibleTeams = allTeams.where((t) {
          final isCaptain = t.captainId != null;
          final sameSport = t.sportId == profileSportId || match.sportName == null;
          return isCaptain && sameSport;
        }).toList();

        if (eligibleTeams.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Icon(Icons.group_off, size: 40, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(
                  'No tienes equipos de ${match.sportName ?? "este deporte"} donde seas capitán.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/crear-equipo'),
                  child: const Text('Crear un equipo', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: eligibleTeams.map((team) {
            final isSelected = _selectedTeam?.id == team.id;
            final hasLogo = team.logo.startsWith('http');

            return GestureDetector(
              onTap: () => setState(() => _selectedTeam = team),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? cs.primary : theme.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.surfaceContainerHighest,
                      backgroundImage: hasLogo ? NetworkImage(team.logo) : null,
                      child: !hasLogo ? Text(team.logo.isNotEmpty ? team.logo : '🛡️', style: const TextStyle(fontSize: 20)) : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(team.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '${team.currentMembers}/${team.maxMembers} jugadores · ${team.sportName}',
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: cs.primary, size: 28)
                    else
                      Icon(Icons.radio_button_unchecked, color: cs.outlineVariant, size: 28),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildNextStepsCard(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text('Próximos pasos', style: theme.textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          for (final step in [
            'Coordina fecha y hora con el capitán rival vía WhatsApp',
            'El organizador configurará el costo de la cancha',
            'Tu equipo recibirá la cuota individual a pagar',
            'Sube tu comprobante de pago al capitán',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(step, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, ColorScheme cs, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.onSurface,
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (_selectedTeam != null && !isLoading) ? () => _handleAccept(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirmar y Retar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
