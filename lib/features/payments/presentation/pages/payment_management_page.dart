import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_state.dart';

enum PaymentFilter { all, pending, paid }

/// Pantalla que gestiona los pagos de canchas del usuario.
class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  State<PaymentManagementPage> createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  PaymentFilter _activeFilter = PaymentFilter.all;
  List<PaymentEntity> _cachedPayments = [];

  @override
  void initState() {
    super.initState();
    // Inicializar caché desde el estado actual del BLoC si ya existe
    final currentState = context.read<PaymentsBloc>().state;
    if (currentState is PaymentsLoaded) {
      _cachedPayments = currentState.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gestión de Pagos',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
            iconTheme: IconThemeData(color: colorScheme.onSurface),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // BARRA DE CARGA "FULL PERSISTENCIA"
                BlocBuilder<PaymentsBloc, PaymentsState>(
                  builder: (context, state) {
                    return MatchDayLoadingBar(isLoading: state is PaymentsLoading);
                  },
                ),
                BlocConsumer<PaymentsBloc, PaymentsState>(
                  listener: (context, state) {
                    if (state is PaymentsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                      );
                    }
                    if (state is PaymentsLoaded) {
                      setState(() => _cachedPayments = state.payments);
                    }
                  },
                  builder: (context, state) {
                    final paymentsToShow = state is PaymentsLoaded ? state.payments : _cachedPayments;
                    final payments = _getFilteredPayments(paymentsToShow);
                    final totalDebt = _calculateTotalDebt(paymentsToShow);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(totalDebt)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                          _buildMicroFilters(colorScheme),
                          const SizedBox(height: 16),
                          if (payments.isEmpty && state is! PaymentsLoading)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: payments.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildPaymentCard(
                                  context,
                                  payments[index],
                                  colorScheme,
                                  isDark,
                                ).animate()
                                 .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                                 .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PaymentEntity> _getFilteredPayments(List<PaymentEntity> list) {
    switch (_activeFilter) {
      case PaymentFilter.all:
        return list;
      case PaymentFilter.pending:
        return list.where((p) => !p.isPaid).toList();
      case PaymentFilter.paid:
        return list.where((p) => p.isPaid).toList();
    }
  }

  double _calculateTotalDebt(List<PaymentEntity> list) {
    return list
        .where((p) => !p.isPaid)
        .fold(0.0, (sum, item) => sum + item.monto);
  }

  Widget _buildSummaryCard(double totalDebt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2AB58E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black54, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'DEUDA TOTAL PENDIENTE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '\$${totalDebt.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Saldo actualizado hoy',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicroFilters(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildFilterButton('Todos', PaymentFilter.all, colorScheme),
        const SizedBox(width: 8),
        _buildFilterButton('Pendientes', PaymentFilter.pending, colorScheme),
        const SizedBox(width: 8),
        _buildFilterButton('Completados', PaymentFilter.paid, colorScheme),
      ],
    );
  }

  Widget _buildFilterButton(String text, PaymentFilter filter, ColorScheme colorScheme) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentEntity payment, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                payment.teamLogo != null && payment.teamLogo!.isNotEmpty
                ? NetworkImage(payment.teamLogo!)
                : null,
            child: payment.teamLogo == null || payment.teamLogo!.isEmpty
                ? const Icon(Icons.sports_soccer, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.teamName,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.concepto,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${payment.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: payment.isPaid
                        ? AppColors.primary
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(context, payment, colorScheme),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, PaymentEntity payment, ColorScheme colorScheme) {
    if (payment.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pagado',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
// ... [No changes to the logic, just passing colorScheme to _showUploadDialog if needed or ensuring consistent styling]

    if (payment.estatusPago == 'reportado') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Reportado',
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return AnimatedBouncingButton(
      onTap: () => _showUploadDialog(context, payment.idPartida, payment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Pagar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, int idPartida, PaymentEntity payment) {
    // En lugar del diálogo, usamos la nueva pantalla nativa:
    context.push('/upload-receipt', extra: {'payment': payment});
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No hay pagos en esta categoría.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
