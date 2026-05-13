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
import '../bloc/payments_event.dart';

enum PaymentFilter { all, pending, paid }

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
    final currentState = context.read<PaymentsBloc>().state;
    if (currentState is PaymentsLoaded) {
      _cachedPayments = currentState.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gestión de Pagos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<PaymentsBloc, PaymentsState>(
            builder: (context, state) {
              return MatchDayLoadingBar(isLoading: state is PaymentsLoading);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PaymentsBloc>().add(LoadMyPaymentsEvent());
              },
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
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
                      final totals = _calculateTotalsByCurrency(paymentsToShow);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumSummaryCard(totals),
                          const SizedBox(height: 32),
                          _buildFilters(colorScheme, isDark),
                          const SizedBox(height: 24),
                          if (payments.isEmpty && state is! PaymentsLoading)
                            _buildEmptyState(isDark)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: payments.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildPremiumPaymentCard(
                                  context,
                                  payments[index],
                                  colorScheme,
                                  isDark,
                                ).animate()
                                 .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                                 .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSummaryCard(Map<String, double> totals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            const Color(0xFF2AB58E),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SALDO PENDIENTE',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.black54, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: totals.entries.map((e) => Text(
              '${e.key}${e.value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Cálculo basado en montos acordados',
                  style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('Todos', PaymentFilter.all, isDark),
          const SizedBox(width: 10),
          _buildFilterChip('Pendientes', PaymentFilter.pending, isDark),
          const SizedBox(width: 10),
          _buildFilterChip('Pagados', PaymentFilter.paid, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PaymentFilter filter, bool isDark) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPaymentCard(BuildContext context, PaymentEntity payment, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: isDark ? Colors.black : Colors.grey[100],
              backgroundImage: payment.teamLogo != null && payment.teamLogo!.isNotEmpty ? NetworkImage(payment.teamLogo!) : null,
              child: payment.teamLogo == null || payment.teamLogo!.isEmpty ? const Icon(Icons.shield_outlined, color: AppColors.primary) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.teamName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.concepto,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  '${payment.currentSymbol}${payment.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: payment.isPaid ? AppColors.primary : Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildActionStatus(context, payment),
        ],
      ),
    );
  }

  Widget _buildActionStatus(BuildContext context, PaymentEntity payment) {
    if (payment.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
            SizedBox(width: 6),
            Text('LISTO', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      );
    }

    if (payment.estatusPago == 'reportado') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_filled_rounded, color: Colors.orangeAccent, size: 14),
            SizedBox(width: 6),
            Text('REVISIÓN', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
          ],
        ),
      );
    }

    return AnimatedBouncingButton(
      onTap: () => context.push('/upload-receipt', extra: {'payment': payment}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFFF5252)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'PAGAR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('Sin movimientos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'No tienes pagos registrados en esta categoría.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<PaymentEntity> _getFilteredPayments(List<PaymentEntity> list) {
    switch (_activeFilter) {
      case PaymentFilter.all: return list;
      case PaymentFilter.pending: return list.where((p) => !p.isPaid).toList();
      case PaymentFilter.paid: return list.where((p) => p.isPaid).toList();
    }
  }

  Map<String, double> _calculateTotalsByCurrency(List<PaymentEntity> list) {
    final Map<String, double> totals = {};
    for (final p in list) {
      if (!p.isPaid) {
        final symbol = p.currentSymbol;
        totals[symbol] = (totals[symbol] ?? 0.0) + p.monto;
      }
    }
    return totals;
  }
}
