import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../../../core/theme/app_colors.dart';

class ConfigureMatchPage extends StatefulWidget {
  final MatchEntity partido;

  const ConfigureMatchPage({super.key, required this.partido});

  @override
  State<ConfigureMatchPage> createState() => _ConfigureMatchPageState();
}

class _ConfigureMatchPageState extends State<ConfigureMatchPage> {
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _bancoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  double _costoActual = 0.0;

  @override
  void initState() {
    super.initState();
    _costoController.addListener(() {
      setState(() {
        _costoActual = double.tryParse(_costoController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _costoController.dispose();
    _bancoController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _handleContactar() async {
    // WhatsApp del capitán rival si tuviéramos el número, 
    // por ahora un placeholder o el número de la cancha si existiera.
    final message = "Hola, soy el capitán rival para el partido del ${widget.partido.fechaInicioEstimada}. ¿Cómo coordinamos?";
    final url = "https://wa.me/?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  void _handleConfirmar(BuildContext context) {
    final costo = double.tryParse(_costoController.text);
    if (costo == null || costo <= 0 || _bancoController.text.isEmpty || _cedulaController.text.isEmpty || _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos con datos válidos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    context.read<MatchesBloc>().add(
      ConfigureMatchEvent(
        matchId: widget.partido.id,
        fecha: widget.partido.fechaInicioEstimada,
        costo: costo,
        banco: _bancoController.text,
        cedula: _cedulaController.text,
        telefono: _telefonoController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurar Encuentro',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      body: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchConfigured) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Encuentro configurado. El estatus ha cambiado a negociación.'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de Equipo Rival
                _buildRivalCard(isDark),
                const SizedBox(height: 24),

                // Estado de la Negociación
                _buildProposalStatus(isDark),
                const SizedBox(height: 24),

                // Card de Costo
                _buildCostoCard(isDark),
                const SizedBox(height: 24),

                // Card de Datos Bancarios
                _buildBankingCard(isDark),
                const SizedBox(height: 24),

                // Próximos Pasos
                _buildNextSteps(isDark),
                const SizedBox(height: 100), // Espacio para el footer fijo
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildFooter(context, isDark),
    );
  }

  Widget _buildRivalCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('⚽', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partido.nombreEquipoA ?? 'Rival Desconocido',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          'Capitán: ${widget.partido.nombreCapitanA ?? 'Pendiente'}',
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botón de WhatsApp (Vibrante Green)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleContactar,
              icon: const Icon(Icons.message, color: Colors.white),
              label: const Text(
                'Contactar Capitán Rival',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Costo de la Cancha',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingresa el costo total de la reserva. El sistema calculará la división equitativa.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _costoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary, size: 32),
              hintText: '0.00',
              hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
              filled: true,
              fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          if (_costoActual > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cuota por jugador (est.)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      Text(
                        '\$${(_costoActual / 22).toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Costo Total', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      Text(
                        '\$${_costoActual.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Tus Datos Bancarios',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Provee tus datos para que los jugadores puedan reportarte sus pagos.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildTextField('Banco / Método de Pago', _bancoController, isDark),
          const SizedBox(height: 12),
          _buildTextField('Cédula / RIF', _cedulaController, isDark),
          const SizedBox(height: 12),
          _buildTextField('Teléfono de Contacto', _telefonoController, isDark, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _buildNextSteps(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos pasos',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildStep('• Coordina fecha y hora con el capitán rival'),
          _buildStep('• Confirma el costo final de la cancha'),
          _buildStep('• Los jugadores verán su cuota en la app'),
          _buildStep('• Gestiona los cobros desde tu dashboard'),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF2A2A2A), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _costoActual > 0 ? () => _handleConfirmar(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: const Color(0xFF2A2A2A),
                  disabledForegroundColor: const Color(0xFF6B7280),
                ),
                child: const Text('Confirmar y Retar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalStatus(bool isDark) {
    final match = widget.partido;
    final propA = match.propuestaCostoA != null;
    final propB = match.propuestaCostoB != null;
    final coincide = propA && propB && 
                    match.propuestaCostoA == match.propuestaCostoB &&
                    match.propuestaFechaA == match.propuestaFechaB;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: coincide ? Colors.green.withValues(alpha: 0.5) : const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de Negociación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _proposalRow('Capitán A (Organizador)', match.propuestaCostoA, match.propuestaFechaA),
          const Divider(color: Color(0xFF2A2A2A), height: 20),
          _proposalRow('Capitán B (Retador)', match.propuestaCostoB, match.propuestaFechaB),
          if (propA && propB && !coincide) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Las propuestas no coinciden. Ambos deben acordar el mismo monto y fecha.', style: TextStyle(color: Colors.orange, fontSize: 11))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _proposalRow(String label, double? costo, DateTime? fecha) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(costo != null ? '\$${costo.toStringAsFixed(2)}' : 'Sin propuesta', style: TextStyle(color: costo != null ? Colors.white : const Color(0xFF4A4A4A), fontWeight: FontWeight.bold, fontSize: 13)),
            if (fecha != null) Text(DateFormat('jm').format(fecha), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
