import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchDetailsEvent(widget.matchId)),
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
          } else if (state is MatchesError) {
            return Scaffold(body: Center(child: Text(state.message)));
          } else if (state is MatchDetailsLoaded) {
            final match = state.match;
            return _buildContent(context, match, isDark);
          }
          return const Scaffold();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MatchEntity match, bool isDark) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Partido #${match.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMapPreview(isDark),
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

  Widget _buildMapPreview(bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : Colors.grey[300]!),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: AppColors.primary, size: 48),
          SizedBox(height: 8),
          Text('Abrir en Google Maps', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
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
            const CircleAvatar(child: Text('⚽')),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Organizador: ${match.idUsuarioOrg}', style: _titleStyle(isDark)),
                const Text('Fútbol Match', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.calendar_today, DateFormat('EEEE, d MMMM').format(match.fechaInicioEstimada), isDark),
        const SizedBox(height: 10),
        _buildDetailRow(Icons.location_on_outlined, 'Cancha #${match.idCancha}', isDark),
      ],
    ));
  }

  Widget _buildNegotiationCard(BuildContext context, MatchEntity match, bool isDark) {
    return _buildCard(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Términos de Negociación', style: _titleStyle(isDark)),
        const SizedBox(height: 16),
        const Text('Propón la fecha y el costo final para llegar a un acuerdo con el otro capitán.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
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
    const totalPlayers = 12; // Mock
    final quota = match.costoTotal / totalPlayers;
    return _buildCard(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen Financiero', style: _titleStyle(isDark)),
        const SizedBox(height: 16),
        _buildFinancialRow('Alquiler de Cancha', '\$${match.costoTotal}', isDark),
        _buildFinancialRow('Jugadores Totales', '$totalPlayers', isDark),
        const Divider(color: Color(0xFF2A2A2A), height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tu Cuota', style: _titleStyle(isDark)),
            Text('\$${quota.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ));
  }

  Widget _buildBottomBar(BuildContext context, MatchEntity match, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {}, // WhatsApp integration
              icon: const Icon(Icons.message_outlined),
              label: const Text('Contactar Rival'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black,
                side: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]!),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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

  TextStyle _titleStyle(bool isDark) => TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
}
