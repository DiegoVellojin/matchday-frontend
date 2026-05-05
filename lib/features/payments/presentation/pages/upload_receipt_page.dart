import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
import '../bloc/payments_state.dart';
import '../../domain/entities/payment_entity.dart';

class UploadReceiptPage extends StatefulWidget {
  final PaymentEntity pago;

  const UploadReceiptPage({super.key, required this.pago});

  @override
  State<UploadReceiptPage> createState() => _UploadReceiptPageState();
}

class _UploadReceiptPageState extends State<UploadReceiptPage> {
  final TextEditingController _referenciaController = TextEditingController();
  String? _selectedFileName;

  @override
  void dispose() {
    _referenciaController.dispose();
    super.dispose();
  }

  void _handleFileSelect() {
    // Simulando selección de archivo
    setState(() {
      _selectedFileName = 'comprobante_transferencia.pdf';
    });
  }

  void _handleSubmit(BuildContext context) {
    if (_selectedFileName == null || _referenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    context.read<PaymentsBloc>().add(
      UploadReceiptEvent(
        partidaId: widget.pago.idPartida,
        urlReciboPago: 'https://storage.example.com/receipts/$_selectedFileName',
        referenciaPago: _referenciaController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Subir Comprobante', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor, height: 1.0),
        ),
      ),
      body: BlocConsumer<PaymentsBloc, PaymentsState>(
        listener: (context, state) {
          if (state is ReceiptUploadedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Comprobante enviado con éxito!', style: TextStyle(color: theme.colorScheme.onPrimary)),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is PaymentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(color: theme.colorScheme.onError)), backgroundColor: theme.colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen del Pago
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen del Pago', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.dividerColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(widget.pago.teamLogo ?? '⚽', style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.pago.teamName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(widget.pago.concepto, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monto a Pagar', style: theme.textTheme.bodySmall),
                          Text('\$${widget.pago.monto.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Destino: Organizador del equipo o cancha deportiva',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Zona de Carga
                Text('Comprobante de Pago', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _handleFileSelect,
                  child: Container(
                    height: 192,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _selectedFileName != null ? theme.colorScheme.primary : theme.dividerColor, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 48, color: _selectedFileName != null ? theme.colorScheme.primary : theme.iconTheme.color?.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFileName ?? 'Toca para subir archivo',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Captura de pantalla o PDF del comprobante', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                if (_selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Text('Archivo seleccionado: $_selectedFileName', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                // Campo de Referencia
                Text('Número de Transacción / Referencia', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 8),
                TextField(
                  controller: _referenciaController,
                  decoration: InputDecoration(
                    hintText: 'Ej: 123456789',
                    prefixIcon: const Icon(Icons.tag),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: Text('Ingresa el número de referencia de tu transferencia o depósito', style: theme.textTheme.bodySmall),
                ),
                // Información Adicional
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
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Text('¿Qué sucede después?', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('• El organizador recibirá tu comprobante', style: theme.textTheme.bodySmall),
                      Text('• Se verificará el pago (24-48 horas)', style: theme.textTheme.bodySmall),
                      Text('• Recibirás una notificación de confirmación', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Botón de Confirmación
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedFileName != null && _referenciaController.text.isNotEmpty) ? () => _handleSubmit(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.upload),
                        SizedBox(width: 8),
                        Text('Confirmar Envío', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
