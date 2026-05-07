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
    _photoUrlController = TextEditingController(text: widget.profile.photoUrl ?? '');
    _passwordController = TextEditingController();
    _completePhoneNumber = widget.profile.phone ?? '';
  }

  String _getInitialNumber() {
    final phone = widget.profile.phone ?? '';
    if (phone.startsWith('+58')) return phone.substring(3);
    if (phone.startsWith('+57')) return phone.substring(3);
    if (phone.startsWith('+1')) return phone.substring(2);
    if (phone.startsWith('+34')) return phone.substring(3);
    if (phone.startsWith('+')) {
      return phone;
    }
    return phone;
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
    if (file != null) {
      setState(() => _imageFile = file);
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    setState(() => _isUploadingImage = true);

    try {
      final storageService = sl<FirebaseStorageService>();
      final path = 'user_photos/photo_${widget.profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storageService.uploadFile(file: _imageFile!, path: path);
      return url;
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Cambiar Contraseña', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? AppColors.border : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? AppColors.border : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
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
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña lista para guardar'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Aplicar', style: TextStyle(color: AppColors.primary)),
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
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.primary,
            ),
          );
          context.pop(); // Volver al perfil
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Editar Perfil',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: isDark ? AppColors.border : Colors.grey.shade300,
              height: 1,
            ),
          ),
        ),

        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileUpdating;
            
            if (state is ProfileInitial || state is ProfileLoading) {
              return const EditProfileSkeleton();
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto de Perfil
                    MatchDayImagePicker(
                      imageFile: _imageFile,
                      imageUrl: _photoUrlController.text,
                      onPickImage: _pickImage,
                      placeholder: Icons.camera_alt_outlined,
                      label: 'Cambiar foto',
                    ),


                    const SizedBox(height: 30),

                    // Nombre Completo
                    const Text(
                      'Nombre Completo',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                        hintText: 'Ingresa tu nombre completo',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppColors.border : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Teléfono
                    const Text(
                      'Teléfono',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      controller: _phoneController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      dropdownTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      dropdownIcon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                      initialCountryCode: _getInitialCountryCode(),
                      languageCode: "es",
                      decoration: InputDecoration(
                        hintText: 'Número de teléfono',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppColors.border : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Botón Cambiar Contraseña
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: isDark ? AppColors.border : Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        icon: const Icon(Icons.lock_outline, color: AppColors.primary),
                        label: const Text('Cambiar Contraseña'),
                      ),
                    ),
                    const SizedBox(height: 40),


                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || _isUploadingImage)
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  String? finalPhotoUrl = _photoUrlController.text.trim();
                                  
                                  final profileBloc = context.read<ProfileBloc>();

                                  if (_imageFile != null) {
                                    final uploadedUrl = await _uploadImage();
                                    if (uploadedUrl != null) {
                                      finalPhotoUrl = uploadedUrl;
                                    }
                                  }

                                  profileBloc.add(
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
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: (isLoading || _isUploadingImage)
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          (isLoading || _isUploadingImage) ? 'Guardando...' : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
