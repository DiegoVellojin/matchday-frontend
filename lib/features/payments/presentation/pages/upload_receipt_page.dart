import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/payments_bloc.dart';
import '../bloc/payments_event.dart';
import '../bloc/payments_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/utils/image_picker_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UploadReceiptPage extends StatefulWidget {
  final PaymentEntity pago;

  const UploadReceiptPage({super.key, required this.pago});

  @override
  State<UploadReceiptPage> createState() => _UploadReceiptPageState();
}

class _UploadReceiptPageState extends State<UploadReceiptPage> {
  final TextEditingController _referenciaController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _handleFileSelect() async {
    final file = await ImagePickerUtils.pickImageFromGallery();
    
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_selectedFile == null || _referenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Subir a Firebase Storage usando el servicio inyectado
      final storageService = sl<FirebaseStorageService>();
      final fileName = 'receipt_${widget.pago.idPartida}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadPath = 'payments/receipts/$fileName';
      
      final downloadUrl = await storageService.uploadFile(
        file: _selectedFile!,
        path: uploadPath,
      );

      if (downloadUrl == null) throw Exception('Error al subir el archivo a Firebase');

      // 2. Enviar la URL al BLoC para persistir en BD
      if (!context.mounted) return;
      context.read<PaymentsBloc>().add(
        UploadReceiptEvent(
          partidaId: widget.pago.idPartida,
          urlReciboPago: downloadUrl,
          referenciaPago: _referenciaController.text,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<PaymentsBloc, PaymentsState>(
        listener: (context, state) {
          if (state is ReceiptUploadedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Comprobante enviado con éxito!'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is PaymentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                stretch: true,
                backgroundColor: theme.cardColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF1A1A1A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.receipt_long, size: 200, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Subir Comprobante',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildPaymentSummaryCard(theme),
                    const SizedBox(height: 24),
                    _buildCaptainBankDetails(theme),
                    const SizedBox(height: 32),
                    Text(
                      'PASO 1: SELECCIONAR ARCHIVO',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUploadArea(theme)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    Text(
                      'PASO 2: REFERENCIA DE PAGO',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReferenceField(theme),
                    const SizedBox(height: 40),
                    _buildSubmitButton(theme, state),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaptainBankDetails(ThemeData theme) {
    if (widget.pago.banco == null && widget.pago.cedula == null && widget.pago.telefono == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'DATOS DEL CAPITÁN (PAGO MÓVIL)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _bankInfoRow(Icons.account_balance, 'Banco', widget.pago.banco ?? 'No especificado'),
          const SizedBox(height: 10),
          _bankInfoRow(Icons.badge_outlined, 'Cédula', widget.pago.cedula ?? 'No especificado'),
          const SizedBox(height: 10),
          _bankInfoRow(Icons.phone_android, 'Teléfono', widget.pago.telefono ?? 'No especificado'),
        ],
      ),
    );
  }

  Widget _bankInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // Copiar al portapapeles (opcional)
          },
          icon: const Icon(Icons.copy_all, size: 18, color: AppColors.primary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: ClipOval(
                  child: (widget.pago.teamLogo != null && widget.pago.teamLogo!.startsWith('http'))
                      ? Image.network(
                          widget.pago.teamLogo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Text('⚽', style: TextStyle(fontSize: 24))),
                        )
                      : Center(
                          child: Text(
                            widget.pago.teamLogo ?? '⚽',
                            style: const TextStyle(fontSize: 24),
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
                      widget.pago.teamName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      widget.pago.concepto,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL A PAGAR', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted, fontSize: 12)),
              Text(
                '\$${widget.pago.monto.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(ThemeData theme) {
    return GestureDetector(
      onTap: _isUploading ? null : _handleFileSelect,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedFile != null ? AppColors.primary : theme.dividerColor,
            width: 2,
            style: _selectedFile != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: _selectedFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedFile!, fit: BoxFit.cover),
                    Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: const Center(
                        child: Icon(Icons.refresh, color: Colors.white, size: 40),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text('Toca para seleccionar captura', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('JPG o PNG del comprobante', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildReferenceField(ThemeData theme) {
    return TextField(
      controller: _referenciaController,
      style: const TextStyle(fontWeight: FontWeight.bold),
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Número de referencia...',
        prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, PaymentsState state) {
    final bool canSubmit = _selectedFile != null && _referenciaController.text.isNotEmpty && !_isUploading;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _handleSubmit(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: theme.dividerColor.withValues(alpha: 0.1),
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: canSubmit ? 8 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: _isUploading || state is PaymentsLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(canSubmit ? Icons.check_circle_outline : Icons.lock_outline),
                  const SizedBox(width: 12),
                  Text(
                    canSubmit ? 'ENVIAR COMPROBANTE' : 'COMPLETA LOS DATOS',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1),
                  ),
                ],
              ),
      ),
    );
  }
}
