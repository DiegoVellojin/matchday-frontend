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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';


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
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'ACEPTAR ENCUENTRO',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
                color: cs.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildRivalCard(context, theme, cs, match),
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECCIONA TU EQUIPO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solo equipos del deporte ${match.sportName ?? "especificado"} donde eres capitán.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildTeamSelector(context, theme, cs, match),
              const SizedBox(height: 32),

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
    final isDark = theme.brightness == Brightness.dark;
    final logo = match.logoEquipoA;
    final hasLogo = logo != null && logo.startsWith('http');

    return Container(
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (match.idEquipoA != null) context.push('/team-dashboard/${match.idEquipoA}');
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? Image.network(logo, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => const Icon(Icons.sports_soccer_rounded, size: 32, color: AppColors.primary))
                        : const Icon(Icons.sports_soccer_rounded, size: 32, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RIVAL',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.nombreEquipoA?.toUpperCase() ?? 'EQUIPO RIVAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            match.sportName?.toUpperCase() ?? 'SIN ESPECIFICAR',
                            style: TextStyle(color: cs.primary, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CAPI: ${match.nombreCapitanA?.toUpperCase() ?? "N/A"}',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
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
              _statBox(theme, cs, Icons.location_on_rounded, match.nombreCancha ?? 'Sede a convenir', 'UBICACIÓN'),
              const SizedBox(width: 12),
              _statBox(theme, cs, match.currentSymbol == '€' ? Icons.euro_rounded : Icons.attach_money_rounded, '${match.currentSymbol}${match.costoTotal.toStringAsFixed(0)}', 'COSTO APROX.'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
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
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: const Text('CONTACTAR CAPITÁN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(ThemeData theme, ColorScheme cs, IconData icon, String value, String label) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector(BuildContext context, ThemeData theme, ColorScheme cs, MatchEntity match) {
    return BlocBuilder<MyTeamsBloc, MyTeamsState>(
      builder: (context, state) {
        if (state is MyTeamsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final allTeams = state is MyTeamsLoaded ? state.teams : <TeamEntity>[];
        final profileState = context.read<ProfileBloc>().state;
        final currentUserId = profileState is ProfileLoaded ? profileState.profile.id : null;
        
        final profileSportId = match.idDeporte;
        final eligibleTeams = allTeams.where((t) {
          final isCaptain = t.captainId == currentUserId && currentUserId != null;
          final sameSport = t.sportId == profileSportId || match.sportName == null;
          return isCaptain && sameSport;
        }).toList();

        if (eligibleTeams.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.group_off_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  'No tienes equipos de ${match.sportName ?? "este deporte"} donde seas capitán.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/crear-equipo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CREAR UN EQUIPO', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: eligibleTeams.map((team) {
            final isSelected = _selectedTeam?.id == team.id;
            final isDark = theme.brightness == Brightness.dark;

            return GestureDetector(
              onTap: () => setState(() => _selectedTeam = team),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1) 
                      : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent),
                      ),
                      child: ClipOval(
                        child: team.logo.startsWith('http')
                            ? Image.network(team.logo, fit: BoxFit.cover)
                            : Center(child: Text('🛡️', style: const TextStyle(fontSize: 24))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name.toUpperCase(), 
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black))
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${team.currentMembers}/${team.maxMembers} JUGADORES · ${team.sportName.toUpperCase()}',
                            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28)
                    else
                      Icon(Icons.radio_button_unchecked, color: isDark ? Colors.white24 : Colors.black12, size: 28),
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
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'PRÓXIMOS PASOS', 
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepItem('Coordina fecha y hora con el rival vía WhatsApp'),
          _buildStepItem('El organizador configurará la sede y costos'),
          _buildStepItem('Cada equipo recibirá su cuota a pagar'),
          _buildStepItem('Sube tu comprobante para confirmar tu asistencia'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, ColorScheme cs, bool isLoading) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (_selectedTeam != null && !isLoading)
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (_selectedTeam != null && !isLoading) ? () => _handleAccept(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('CONFIRMAR Y RETAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
