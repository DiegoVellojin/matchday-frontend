import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../config/presentation/bloc/config_bloc.dart';

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
      final fileName =
          'receipt_${widget.pago.idPartida}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadPath = 'payments/receipts/$fileName';

      final downloadUrl = await storageService.uploadFile(
        file: _selectedFile!,
        path: uploadPath,
      );

      if (downloadUrl == null) {
        throw Exception('Error al subir el archivo a Firebase');
      }

      // 2. Enviar la URL al BLoC para persistir en BD
      if (!context.mounted) return;

      final configState = context.read<ConfigBloc>().state;
      final rateData = configState.rates[widget.pago.moneda ?? 'USD'];
      final double? rate = rateData != null
          ? (rateData['monto_bs'] as num).toDouble()
          : null;

      context.read<PaymentsBloc>().add(
        UploadReceiptEvent(
          partidaId: widget.pago.idPartida,
          urlReciboPago: downloadUrl,
          referenciaPago: _referenciaController.text,
          tasaUsadaBs: rate,
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: BlocConsumer<PaymentsBloc, PaymentsState>(
        listener: (context, state) {
          if (state is ReceiptUploadedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Comprobante enviado con éxito! 🚀'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is PaymentsError) {
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPaymentSummaryCard(theme, isDark)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),

                    _buildCaptainBankDetails(
                      theme,
                      isDark,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 32),

                    _buildSectionHeader('PASO 1: SELECCIONAR ARCHIVO', isDark),
                    const SizedBox(height: 12),
                    _buildUploadArea(theme, isDark)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1),
                        ),
                    const SizedBox(height: 32),

                    _buildSectionHeader('PASO 2: REFERENCIA DE PAGO', isDark),
                    const SizedBox(height: 12),
                    _buildReferenceField(
                      theme,
                      isDark,
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                    const SizedBox(height: 32),

                    _buildDisclaimerCard(isDark),
                    const SizedBox(height: 32),

                    _buildSubmitButton(theme, isDark, state)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 400.ms)
                        .shimmer(delay: 2.seconds, duration: 1.5.seconds),
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

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 250,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          'SUBIR COMPROBANTE',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCaptainBankDetails(ThemeData theme, bool isDark) {
    if (widget.pago.banco == null &&
        widget.pago.cedula == null &&
        widget.pago.telefono == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PAGO MÓVIL DESTINO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final text =
                      "Banco: ${widget.pago.banco}\nCédula: ${widget.pago.cedula}\nTeléfono: ${widget.pago.telefono}";
                  Clipboard.setData(ClipboardData(text: text)).then((_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Todos los datos copiados al portapapeles',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  });
                },
                icon: const Icon(
                  Icons.copy_all_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'COPIAR TODO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _bankInfoRow(
            Icons.account_balance_outlined,
            'Banco',
            widget.pago.banco ?? 'No especificado',
            isDark,
          ),
          _bankDivider(isDark),
          _bankInfoRow(
            Icons.badge_outlined,
            'Cédula',
            widget.pago.cedula ?? 'No especificado',
            isDark,
          ),
          _bankDivider(isDark),
          _bankInfoRow(
            Icons.phone_android_rounded,
            'Teléfono',
            widget.pago.telefono ?? 'No especificado',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _bankDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        height: 1,
      ),
    );
  }

  Widget _bankInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value)).then((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copiado al portapapeles'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            });
          },
          icon: const Icon(
            Icons.copy_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child:
                      (widget.pago.teamLogo != null &&
                          widget.pago.teamLogo!.startsWith('http'))
                      ? Image.network(widget.pago.teamLogo!, fit: BoxFit.cover)
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.pago.concepto.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 20),
          BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, state) {
              final rateData = state.rates[widget.pago.moneda ?? 'USD'];
              final double? rate = rateData != null
                  ? (rateData['monto_bs'] as num).toDouble()
                  : null;
              final amountBs = rate != null ? widget.pago.monto * rate : null;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL A REPORTAR',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (amountBs != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bs. ${amountBs.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Tasa BCV: ${rate!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.pago.currentSymbol}${widget.pago.monto.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _isUploading ? null : _handleFileSelect,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _selectedFile != null
                ? AppColors.primary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05)),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedFile!, fit: BoxFit.cover),
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'CAMBIAR ARCHIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Seleccionar Comprobante',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PNG o JPG de la transacción',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildReferenceField(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _referenciaController,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Número de operación / referencia',
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, bool isDark, PaymentsState state) {
    final bool canSubmit =
        _selectedFile != null &&
        _referenciaController.text.isNotEmpty &&
        !_isUploading;

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: canSubmit
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? () => _handleSubmit(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: _isUploading || state is PaymentsLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canSubmit ? Icons.send_rounded : Icons.lock_outline_rounded,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    canSubmit ? 'ENVIAR REPORTE' : 'COMPLETA LOS DATOS',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDisclaimerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POLÍTICA DE PAGOS',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'No habrá reembolsos de pagos. La aplicación no maneja ni se hace responsable de transacciones realizadas por canales externos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
