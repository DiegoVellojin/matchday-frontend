import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/matches_bloc.dart';
import '../../domain/entities/match_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../config/presentation/bloc/config_bloc.dart';
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
  String _monedaSeleccionada = 'USD';

  @override
  void initState() {
    super.initState();
    context.read<ConfigBloc>().add(FetchRatesEvent());
    _costoController.text = widget.partido.costoTotal.toString();
    _costoActual = widget.partido.costoTotal;
    _monedaSeleccionada = widget.partido.moneda;

    _costoController.addListener(() {
      setState(() {
        _costoActual = double.tryParse(_costoController.text) ?? 0.0;
      });
    });

    // Precargar datos si ya existen
    _bancoController.text = widget.partido.bancoReceptor ?? '';
    _cedulaController.text = widget.partido.cedulaReceptora ?? '';
    _telefonoController.text = widget.partido.telefonoReceptor ?? '';
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
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    final isCaptainA = currentUserId == widget.partido.idUsuarioOrg;
    final rivalPhone = isCaptainA
        ? widget.partido.telefonoCapitanB
        : widget.partido.telefonoCapitanA;

    if (rivalPhone == null || rivalPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay número de teléfono disponible para el capitán rival',
          ),
        ),
      );
      return;
    }

    final cleanPhone = rivalPhone.replaceAll(RegExp(r'\D'), '');
    final message =
        "Hola, soy el capitán rival para el partido del ${DateFormat('dd/MM/yyyy').format(widget.partido.fechaInicioEstimada)}. ¿Cómo coordinamos?";
    final url =
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";

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

  void _handleConfirmar(BuildContext context) {
    final costo = double.tryParse(_costoController.text);
    if (costo == null ||
        costo <= 0 ||
        _bancoController.text.isEmpty ||
        _cedulaController.text.isEmpty ||
        _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa todos los campos con datos válidos',
          ),
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
        moneda: _monedaSeleccionada,
        banco: _bancoController.text,
        cedula: _cedulaController.text,
        telefono: _telefonoController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<MatchesBloc, MatchesState>(
        listener: (context, state) {
          if (state is MatchConfigured) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Configuración enviada. Esperando acuerdo.'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, colorScheme),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildRivalCard(context, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    _buildProposalStatus(context, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    _buildCostoCard(context, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    _buildBankingCard(context, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    _buildSecurityNote(context, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 350.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),

                    _buildNextSteps(isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildFooter(context, isDark)
          .animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Configurar Encuentro',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildRivalCard(BuildContext context, bool isDark) {
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'rival_logo_${widget.partido.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipOval(
                    child: (widget.partido.logoEquipoA != null && widget.partido.logoEquipoA!.isNotEmpty && widget.partido.logoEquipoA != 'null')
                        ? Image.network(
                            widget.partido.logoEquipoA!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(child: Text('🛡️', style: TextStyle(fontSize: 28))),
                          )
                        : const Center(
                            child: Text('🛡️', style: TextStyle(fontSize: 28)),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partido.nombreEquipoA ?? 'Rival Desconocido',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Capitán: ${widget.partido.nombreCapitanA ?? 'Pendiente'}',
                      style: TextStyle(color: textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _handleContactar,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(
                'Coordinar por WhatsApp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostoCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, configState) {
        final rateData = configState.rates[_monedaSeleccionada];
        // Forzamos la búsqueda de la tasa. Si no existe en el mapa, intentamos buscarla de nuevo.
        final double rate = (rateData != null && rateData['monto_bs'] != null) 
            ? (rateData['monto_bs'] as num).toDouble() 
            : 1.0;
        final bsAmount = _costoActual * rate;
        final cuotaDolar = _costoActual / (widget.partido.cuposTotales > 0 ? widget.partido.cuposTotales : 1);
        final cuotaBs = cuotaDolar * rate;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [colorScheme.surface, colorScheme.surface.withValues(alpha: 0.8)]
                : [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Costo de Cancha',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  if (configState.isLoading)
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _costoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _monedaSeleccionada,
                        elevation: 16,
                        dropdownColor: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('\$', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
                          DropdownMenuItem(value: 'EUR', child: Text('€', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
                        ],
                        onChanged: (val) => setState(() => _monedaSeleccionada = val!),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  hintText: '0.00',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_costoActual > 0) ...[
                Center(
                  child: Text(
                    '≈ Bs. ${NumberFormat("#,##0.00", "es_VE").format(bsAmount)}',
                    style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildFinancialRow(
                  'Cuota por jugador:',
                  '${_monedaSeleccionada == 'USD' ? '\$' : '€'}${cuotaDolar.toStringAsFixed(2)}',
                  AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildFinancialRow(
                  'Equivalente en Bolívares:',
                  'Bs. ${NumberFormat("#,##0.00", "es_VE").format(cuotaBs)}',
                  textMuted,
                  isSecondary: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialRow(String label, String value, Color valueColor, {bool isSecondary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSecondary ? Colors.grey : null,
            fontSize: isSecondary ? 12 : 14,
            fontWeight: isSecondary ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: isSecondary ? 13 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Protocolo de Seguridad Financiera',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  'Por integridad de los datos, todos los pagos en Bolívares deben realizarse estrictamente a la tasa oficial del Banco Central de Venezuela (BCV) vigente al momento de la transacción.',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.blue[200] : Colors.blue[800], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankingCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Tus Datos de Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            'Banco / Plataforma',
            _bancoController,
            Icons.account_balance,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildStyledTextField(
            'Documento (Cédula/RIF)',
            _cedulaController,
            Icons.badge_outlined,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildStyledTextField(
            'Teléfono Móvil',
            _telefonoController,
            Icons.phone_android,
            isDark,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMuted, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: textMuted),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }

  Widget _buildNextSteps(bool isDark) {
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Recordatorio Importante',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            'Ambos capitanes deben acordar el mismo costo.',
            textMuted,
          ),
          _buildStepItem(
            'Los jugadores pagarán su cuota directamente a ti.',
            textMuted,
          ),
          _buildStepItem(
            'Podrás verificar los pagos desde el Dashboard.',
            textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalStatus(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final match = widget.partido;
    final coincide = match.propuestaCostoA != null && 
                    match.propuestaCostoA == match.propuestaCostoB;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: coincide ? Colors.green.withValues(alpha: 0.05) : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: coincide ? Colors.green.withValues(alpha: 0.2) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                coincide ? Icons.check_circle_outline : Icons.handshake_outlined,
                color: coincide ? Colors.green : AppColors.primary,
              ),
              const SizedBox(width: 10),
              const Text(
                'Estado de la Propuesta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _proposalRow(
            context,
            'Tu Equipo (Org)',
            match.propuestaCostoA,
            isDark,
            match.symbolA,
          ),
          const SizedBox(height: 8),
          _proposalRow(
            context,
            'Rival (Retador)',
            match.propuestaCostoB,
            isDark,
            match.symbolB,
          ),
          if (match.propuestaCostoA != null && 
              match.propuestaCostoB != null && 
              !coincide)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '⚠️ Los montos no coinciden. Sigue negociando.',
                style: TextStyle(
                  color: Colors.orange[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _proposalRow(BuildContext context, String label, double? amount, bool isDark, String symbol) {
    final textMuted = isDark ? const Color(0xFF9CA3AF) : Colors.black54;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 13)),
        Text(
          amount != null ? '$symbol${amount.toStringAsFixed(2)}' : 'Sin propuesta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount != null ? Theme.of(context).colorScheme.onSurface : textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _costoActual > 0
                  ? () => _handleConfirmar(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Enviar Propuesta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
