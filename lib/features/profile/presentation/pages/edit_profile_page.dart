import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/widgets/matchday_image_picker.dart';
import '../../../../core/utils/image_picker_utils.dart';

import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/edit_profile_skeleton.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileEntity profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  bool _isUploadingImage = false;
  String _completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: _getInitialNumber());
    _photoUrlController = TextEditingController(
      text: widget.profile.photoUrl ?? '',
    );
    _passwordController = TextEditingController();
    _completePhoneNumber = widget.profile.phone ?? '';
  }

  String _getInitialNumber() {
    final phone = widget.profile.phone ?? '';
    if (phone.startsWith('+58')) return phone.substring(3);
    if (phone.startsWith('+57')) return phone.substring(3);
    if (phone.startsWith('+1')) return phone.substring(2);
    if (phone.startsWith('+34')) return phone.substring(3);
    return phone.startsWith('+') ? phone : phone;
  }

  String _getInitialCountryCode() {
    final phone = widget.profile.phone ?? '';
    if (phone.startsWith('+58')) return 'VE';
    if (phone.startsWith('+57')) return 'CO';
    if (phone.startsWith('+1')) return 'US';
    if (phone.startsWith('+34')) return 'ES';
    return 'VE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePickerUtils.pickImageFromGallery();
    if (file != null) setState(() => _imageFile = file);
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    setState(() => _isUploadingImage = true);
    try {
      final storageService = sl<FirebaseStorageService>();
      final path =
          'user_photos/photo_${widget.profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await storageService.uploadFile(file: _imageFile!, path: path);
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _showChangePasswordDialog() {
    final confirmController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Cambiar Contraseña',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernTextField(
                controller: _passwordController,
                label: 'Nueva Contraseña',
                icon: Icons.lock_outline,
                isDark: isDark,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: confirmController,
                label: 'Confirmar Contraseña',
                icon: Icons.lock_reset_rounded,
                isDark: isDark,
                obscureText: true,
                validator: (v) =>
                    (v != _passwordController.text) ? 'No coinciden' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _passwordController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'CANCELAR',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate())
                Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'APLICAR',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado'),
              backgroundColor: AppColors.primary,
            ),
          );
          context.pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Editar Perfil',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileUpdating;
            if (state is ProfileInitial || state is ProfileLoading)
              return const EditProfileSkeleton();

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: MatchDayImagePicker(
                        imageFile: _imageFile,
                        imageUrl: _photoUrlController.text,
                        onPickImage: _pickImage,
                        placeholder: Icons.person_rounded,
                        label: 'CAMBIAR FOTO',
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildModernTextField(
                      controller: _nameController,
                      label: 'NOMBRE COMPLETO',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'TELÉFONO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    IntlPhoneField(
                      controller: _phoneController,
                      initialCountryCode: _getInitialCountryCode(),
                      languageCode: "es",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: _modernInputDecoration(
                        isDark,
                        Icons.phone_android_rounded,
                        'Número de teléfono',
                      ),
                      onChanged: (phone) =>
                          _completePhoneNumber = phone.completeNumber,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        icon: const Icon(Icons.lock_outline, size: 20),
                        label: const Text(
                          'CAMBIAR CONTRASEÑA',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (isLoading || _isUploadingImage)
                            ? null
                            : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: (isLoading || _isUploadingImage)
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                'GUARDAR CAMBIOS',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    String? finalPhotoUrl = _photoUrlController.text.trim();
    if (_imageFile != null) {
      final uploadedUrl = await _uploadImage();
      if (!mounted) return;
      if (uploadedUrl != null) finalPhotoUrl = uploadedUrl;
    }
    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        name: _nameController.text.trim(),
        phone: _completePhoneNumber.isNotEmpty
            ? _completePhoneNumber
            : _phoneController.text.trim(),
        photoUrl: finalPhotoUrl.isNotEmpty ? finalPhotoUrl : null,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: _modernInputDecoration(isDark, icon, 'Ingresa tu $label'),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _modernInputDecoration(
    bool isDark,
    IconData icon,
    String hint,
  ) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
