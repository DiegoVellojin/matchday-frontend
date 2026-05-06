import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;
  const MatchDetailsPage({super.key, required this.matchId});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void _handleContactar(MatchEntity match) async {
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final isCaptainA = currentUserId == match.idUsuarioOrg;
    final rivalPhone = isCaptainA ? match.telefonoCapitanB : match.telefonoCapitanA;

    if (rivalPhone == null || rivalPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay número de teléfono disponible para el capitán rival')),
      );
      return;
    }

    final cleanPhone = rivalPhone.replaceAll(RegExp(r'\D'), '');
    final message = "Hola, soy el capitán rival para el partido del ${DateFormat('dd/MM/yyyy').format(match.fechaInicioEstimada)}. ¿Cómo coordinamos?";
    final url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchDetailsEvent(widget.matchId)),
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
          } else if (state is MatchDetailsLoaded) {
            final match = state.match;
            return _buildContent(context, match, isDark);
          }
          return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text('Partido #${match.id}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMapPreview(match, isDark),
            const SizedBox(height: 20),
            _buildStatusBadge(match.estatus),
            const SizedBox(height: 20),
            _buildMatchInfoCard(match, isDark),
            const SizedBox(height: 16),
            if (match.estatus == 'negociando') _buildNegotiationCard(context, match, isDark),
            if (match.estatus == 'pendiente_pago') _buildFinancialCard(match, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, match, isDark),
    );
  }

  Widget _buildMapPreview(MatchEntity match, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final query = match.nombreCancha ?? 'Cancha #${match.idCancha}';
        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo abrir Google Maps')),
            );
          }
        }
      },
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 48),
            SizedBox(height: 8),
            Text('Abrir en Google Maps', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isNeg = status == 'negociando';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isNeg ? Colors.blue : Colors.orange).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isNeg ? Colors.blue : Colors.orange).withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: isNeg ? Colors.blue : Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildMatchInfoCard(MatchEntity match, bool isDark) {
    return _buildCard(isDark, child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (match.logoEquipoA != null && match.logoEquipoA!.startsWith('http'))
                    ? Image.network(
                        match.logoEquipoA!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
                      )
                    : const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizador: ${match.nombreCapitanA ?? 'Capi'}', style: _titleStyle(isDark, context)),
                GestureDetector(
                  onTap: () {
                    if (match.idEquipoA != null) {
                      context.push('/team-dashboard/${match.idEquipoA}');
                    }
                  },
                  child: Text(
                    'Equipo: ${match.nombreEquipoA ?? 'Sin Equipo'}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(match.sportName ?? 'Deporte Match', style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.calendar_today, DateFormat('EEEE, d MMMM').format(match.fechaInicioEstimada), isDark),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.location_on_outlined, match.nombreCancha ?? 'Cancha #${match.idCancha}', isDark),
      ],
    ));
  }

  Widget _buildNegotiationCard(BuildContext context, MatchEntity match, bool isDark) {
    return _buildCard(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Términos de Negociación', style: _titleStyle(isDark, context)),
        const SizedBox(height: 16),
        Text('Propón la fecha y el costo final para llegar a un acuerdo con el otro capitán.',
            style: TextStyle(color: isDark ? Colors.grey : Colors.black54, fontSize: 13)),
        const SizedBox(height: 20),
        _buildNegotiationField('Costo Total Producido', _costController, Icons.attach_money, isDark),
        const SizedBox(height: 12),
        _buildNegotiationField('Fecha Acordada', _dateController, Icons.calendar_today, isDark, onTap: () async {
          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
          if (date != null) {
            setState(() {
              selectedDate = date;
              _dateController.text = DateFormat('yyyy-MM-dd').format(date);
            });
          }
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<MatchesBloc>().add(ProposeTermsEvent(
                matchId: match.id,
                fecha: selectedDate,
                costo: double.tryParse(_costController.text) ?? 0.0,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Enviar Propuesta', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ));
  }

  Widget _buildFinancialCard(MatchEntity match, bool isDark) {
    const totalPlayers = 22; // Asumimos 11 vs 11 por defecto
    final quota = match.costoTotal / totalPlayers;
    return _buildCard(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen Financiero', style: _titleStyle(isDark, context)),
        const SizedBox(height: 16),
        _buildFinancialRow('Alquiler de Cancha', '\$${match.costoTotal}', isDark),
        _buildFinancialRow('Jugadores Totales', '$totalPlayers', isDark),
        Divider(color: Theme.of(context).dividerColor, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tu Cuota', style: _titleStyle(isDark, context)),
            Text('\$${quota.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ));
  }

  Widget _buildBottomBar(BuildContext context, MatchEntity match, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleContactar(match),
              icon: const Icon(Icons.message_outlined),
              label: const Text('Contactar Rival'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (match.estatus == 'pendiente_pago') ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pagos'),
                icon: const Icon(Icons.attach_money),
                label: const Text('Pagar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNegotiationField(String label, TextEditingController controller, IconData icon, bool isDark, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: textMuted, size: 20),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 20, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  TextStyle _titleStyle(bool isDark, BuildContext context) => TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
}
