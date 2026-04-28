import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/usecases/create_team_usecase.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '11');

  int _selectedSportId = 1;
  bool _isRecruiting = true;
  File? _imageFile;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _sports = [
    {'id': 1, 'name': 'Fútbol'},
    {'id': 2, 'name': 'Baloncesto'},
    {'id': 3, 'name': 'Tenis'},
    {'id': 4, 'name': 'Voleibol'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Reducimos dimensiones y calidad para no saturar el storage (Compresión automática)
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadLogo() async {
    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(
        'team_logos/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final uploadTask = await fileRef.putFile(_imageFile!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error subiendo imagen a Firebase: $e');
      return null;
    }
  }

  Future<void> _createTeam() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el nombre del equipo.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Subir imagen a Firebase si se seleccionó una
      String? logoUrl = await _uploadLogo();

      // 2. Usar el Caso de Uso de Clean Architecture
      final createTeamUseCase = sl<CreateTeamUseCase>();

      final result = await createTeamUseCase(
        name: _nameController.text.trim(),
        sportId: _selectedSportId,
        logoUrl: logoUrl,
        description: _descriptionController.text.trim(),
        isRecruiting: _isRecruiting,
        maxMembers: int.tryParse(_maxMembersController.text) ?? 11,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Equipo creado exitosamente!'),
                backgroundColor: AppColors.primary,
              ),
            );
            context.pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el equipo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Crear Nuevo Equipo',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo del Equipo
                  const Text(
                    'Logo del Equipo',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _imageFile != null
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),

                      child: _imageFile != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _imageFile!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.textMuted,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Subir Logo del Equipo',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PNG, JPG hasta 5MB',
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre del Equipo
                  const Text(
                    'Nombre del Equipo',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'Ingresa el nombre del equipo',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seleccionar Deporte
                  const Text(
                    'Seleccionar Deporte',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(

                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedSportId,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textMuted,
                        ),
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.textMain),
                        items: _sports.map((sport) {
                          return DropdownMenuItem<int>(
                            value: sport['id'] as int,
                            child: Text(sport['name'] as String),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSportId = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Descripción Corta
                  const Text(
                    'Descripción Corta / Lema',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'Cuéntale a otros jugadores sobre tu equipo...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reclutamiento Activo Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reclutando Activamente',
                                style: TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Permite que otros jugadores vean que buscas miembros',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Switch(
                          value: _isRecruiting,
                          activeColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.border,
                          onChanged: (val) {
                            setState(() => _isRecruiting = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Máximo Miembros
                  const Text(
                    'Tamaño Máximo del Equipo',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _maxMembersController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'Ej. 11 para Fútbol',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Espacio para el botón fijo
                ],
              ),
            ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Crear Equipo & Invitar Amigos',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

      ),
    );
  }
}
