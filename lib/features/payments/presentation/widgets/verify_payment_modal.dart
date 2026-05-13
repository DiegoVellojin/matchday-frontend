import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
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
    final int userId = jugador['id'] ?? 0;
    if (userId == 0) return;

    context.read<PaymentsBloc>().add(
      VerifyPaymentEvent(partidaId: partidaId, userId: userId),
    );
    Navigator.pop(context);
  }

  void _handleRechazar(BuildContext context) {
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
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar modal
            },
            child: Text('Rechazar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showZoomedImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withValues(alpha: 0.9)),
            ),
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: (jugador['url_recibo_pago'] != null && jugador['url_recibo_pago'].toString().startsWith('http'))
                  ? Image.network(
                      jugador['url_recibo_pago'],
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.image, size: 100, color: Colors.white),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final String refText = (jugador['referencia'] != null && jugador['referencia'].toString().isNotEmpty)
        ? jugador['referencia']
        : 'SIN REF';

    final Map<String, String> comprobante = {
      'concepto': (jugador['concepto'] ?? 'Pago de Partido').toString(),
      'referencia': refText.toString(),
      'fecha': (jugador['fecha'] ?? 'Recién enviado').toString(),
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verificar Pago', 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w900, 
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      )
                    ),
                    Text(
                      'REVISIÓN DE COMPROBANTE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Player Card
                _buildPlayerHeader(isDark),
                const SizedBox(height: 24),
                
                // Transaction Details Card
                _buildDetailsCard(context, isDark, comprobante),
                const SizedBox(height: 24),
                
                // Receipt Preview
                _buildReceiptCard(context, isDark),
                const SizedBox(height: 24),
                
                // Verification Checklist
                _buildChecklistCard(isDark),
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildPlayerHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipOval(
              child: (jugador['url_foto_perfil'] != null && jugador['url_foto_perfil'].toString().startsWith('http'))
                  ? Image.network(
                      jugador['url_foto_perfil'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 30),
                    )
                  : Center(child: Text(jugador['avatar'] ?? '👤', style: const TextStyle(fontSize: 28))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORDEN DE PAGO DE', 
                  style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                ),
                Text(
                  jugador['nombre'] ?? 'Jugador', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool isDark, Map<String, String> comprobante) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, Icons.receipt_long_rounded, 'CONCEPTO', comprobante['concepto']!, isDark),
          _buildDivider(isDark),
          _buildDetailRow(
            context, 
            Icons.payments_rounded, 
            'MONTO REPORTADO', 
            '\$${monto.toStringAsFixed(2)}', 
            isDark,
            isAmount: true
          ),
          _buildDivider(isDark),
          _buildDetailRow(context, Icons.fingerprint_rounded, 'NRO. REFERENCIA', comprobante['referencia']!, isDark, isRef: true),
          _buildDivider(isDark),
          _buildDetailRow(context, Icons.event_available_rounded, 'FECHA REPORTE', comprobante['fecha']!, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, bool isDark, {bool isAmount = false, bool isRef = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              if (isRef)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value, 
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                )
              else
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: isAmount ? 20 : 14, 
                    fontWeight: FontWeight.w900,
                    color: isAmount ? AppColors.primary : (isDark ? Colors.white : Colors.black),
                  )
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), height: 1),
    );
  }

  Widget _buildReceiptCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_search_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'COMPROBANTE ADJUNTO', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showZoomedImage(context),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: (jugador['url_recibo_pago'] != null && jugador['url_recibo_pago'].toString().startsWith('http'))
                    ? Hero(
                        tag: 'receipt_${jugador['id']}',
                        child: Image.network(
                          jugador['url_recibo_pago'],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                          },
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      )
                    : const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(
              child: Text(
                'Toca para ampliar imagen', 
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(bool isDark) {
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
          const Text(
            'RECORDATORIO DE SEGURIDAD', 
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
          ),
          const SizedBox(height: 12),
          _checkItem('Confirma que el monto sea el correcto'),
          _checkItem('Verifica la autenticidad de la referencia'),
          _checkItem('Asegúrate de que no sea un recibo duplicado'),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              onPressed: () => _handleRechazar(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: EdgeInsets.zero,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'RECHAZAR',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _handleAprobar(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: EdgeInsets.zero,
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'APROBAR PAGO',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
