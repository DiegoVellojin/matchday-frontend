import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsBloc>(
      create: (context) => sl<PaymentsBloc>()..add(LoadMyPaymentsEvent()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Gestión de Pagos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: BlocConsumer<PaymentsBloc, PaymentsState>(
          listener: (context, state) {
            if (state is PaymentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PaymentsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is PaymentsLoaded) {
              final payments = _getFilteredPayments(state.payments);
              final totalDebt = _calculateTotalDebt(state.payments);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(totalDebt),
                    const SizedBox(height: 20),
                    _buildMicroFilters(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: payments.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              itemCount: payments.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildPaymentCard(
                                  context,
                                  payments[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
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

  Widget _buildMicroFilters() {
    return Row(
      children: [
        _buildFilterButton('Todos', PaymentFilter.all),
        const SizedBox(width: 8),
        _buildFilterButton('Pendientes', PaymentFilter.pending),
        const SizedBox(width: 8),
        _buildFilterButton('Completados', PaymentFilter.paid),
      ],
    );
  }

  Widget _buildFilterButton(String text, PaymentFilter filter) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.background : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentEntity payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.concepto,
                  style: const TextStyle(
                    color: AppColors.textMuted,
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
          _buildActionButton(context, payment),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, PaymentEntity payment) {
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
