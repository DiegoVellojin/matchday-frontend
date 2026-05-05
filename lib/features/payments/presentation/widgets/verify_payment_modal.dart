import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';

class VerifyPaymentModal extends StatelessWidget {
  final Map<String, dynamic> jugador;
  final double monto;
  final int partidaId;

  const VerifyPaymentModal({
    super.key,
    required this.jugador,
    required this.monto,
    required this.partidaId,
  });

  static void show(BuildContext context, {required Map<String, dynamic> jugador, required double monto, required int partidaId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VerifyPaymentModal(jugador: jugador, monto: monto, partidaId: partidaId),
    );
  }

  void _handleAprobar(BuildContext context) {
    context.read<PaymentsBloc>().add(
      VerifyPaymentEvent(partidaId: partidaId, userId: jugador['id']),
    );
    Navigator.pop(context);
  }

  void _handleRechazar(BuildContext context) {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Rechazar Pago', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Text('¿Estás seguro de rechazar el pago de ${jugador['nombre']}?', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Lógica de rechazo...
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar modal
            },
            child: Text('Rechazar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data for receipt
    final comprobante = {
      'concepto': 'Reserva Cancha - Sábado 26 Abril',
      'referencia': 'TRX-20260425-8392',
      'fecha': '25 de Abril, 2026 - 3:45 PM',
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verificar Pago', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Player Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(jugador['avatar'] ?? '👤', style: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pago de', style: theme.textTheme.bodySmall),
                          Text(jugador['nombre'] ?? 'Jugador', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Transaction Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detalles de la Transacción', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDetailRow(context, Icons.person, 'Concepto', comprobante['concepto']!),
                      Divider(color: theme.dividerColor, height: 24),
                      _buildDetailRow(context, Icons.attach_money, 'Monto Pagado', '\$${monto.toStringAsFixed(2)}', valueColor: theme.colorScheme.primary, valueSize: 24),
                      Divider(color: theme.dividerColor, height: 24),
                      _buildDetailRow(context, Icons.tag, 'Número de Referencia', comprobante['referencia']!, isBadge: true),
                      Divider(color: theme.dividerColor, height: 24),
                      _buildDetailRow(context, Icons.calendar_today, 'Fecha de Envío', comprobante['fecha']!),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Receipt Image
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Comprobante Adjunto', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.image, size: 64, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Center(child: Text('Toca para ampliar la imagen', style: TextStyle(fontSize: 12))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Información de Verificación
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verificación de Pago', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('• Verifica que el monto coincida con la cuota', style: theme.textTheme.bodySmall),
                      Text('• Confirma que la referencia sea válida', style: theme.textTheme.bodySmall),
                      Text('• Revisa que la fecha sea correcta', style: theme.textTheme.bodySmall),
                      Text('• Comprueba que el comprobante sea legible', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleRechazar(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Rechazar Pago'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAprobar(context),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Aprobar Pago'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor, double valueSize = 14, bool isBadge = false}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              if (isBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(value, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                )
              else
                Text(value, style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.bold, color: valueColor ?? theme.textTheme.bodyLarge?.color)),
            ],
          ),
        ),
      ],
    );
  }
}
