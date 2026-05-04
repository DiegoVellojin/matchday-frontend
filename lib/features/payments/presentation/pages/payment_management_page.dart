import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
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
      appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Gestión de Pagos',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          elevation: 0,
        ),
        body: Column(
          children: [
            // BARRA DE CARGA "FULL PERSISTENCIA"
            BlocBuilder<PaymentsBloc, PaymentsState>(
              builder: (context, state) {
                return MatchDayLoadingBar(isLoading: state is PaymentsLoading);
              },
            ),

            Expanded(
              child: BlocConsumer<PaymentsBloc, PaymentsState>(
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

                  if (state is PaymentsLoading && paymentsToShow.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final payments = _getFilteredPayments(paymentsToShow);
                  final totalDebt = _calculateTotalDebt(paymentsToShow);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(totalDebt),
                        const SizedBox(height: 20),
                        _buildMicroFilters(colorScheme),
                        const SizedBox(height: 16),
                        Expanded(
                          child: payments.isEmpty && state is! PaymentsLoading
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<PaymentsBloc>().add(LoadMyPaymentsEvent());
                                  },
                                  child: ListView.separated(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: payments.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      return _buildPaymentCard(
                                        context,
                                        payments[index],
                                        colorScheme,
                                        isDark,
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deuda Total Pendiente',
            style: TextStyle(
              color: AppColors.background,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalDebt.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentEntity payment, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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

    return ElevatedButton(
      onPressed: () => _showUploadDialog(context, payment.idPartida),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        'Pagar',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, int idPartida) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Subir Comprobante',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'URL de la imagen del comprobante',
              labelStyle: TextStyle(color: AppColors.textMuted),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<PaymentsBloc>().add(
                    UploadReceiptEvent(
                      partidaId: idPartida,
                      urlReciboPago: controller.text,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
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
