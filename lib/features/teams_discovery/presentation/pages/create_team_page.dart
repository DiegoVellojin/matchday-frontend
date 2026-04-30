import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_picker_utils.dart';
import '../../../../core/widgets/matchday_image_picker.dart';


import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/theme/app_colors.dart';

import '../../application/usecases/create_team_usecase.dart';
import '../../application/usecases/get_sports_usecase.dart';
import '../../domain/entities/sport_entity.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '11');

  int? _selectedSportId;
  bool _isRecruiting = true;
  File? _imageFile;
  bool _isLoading = false;
  bool _isLoadingSports = true;

  List<SportEntity> _sports = [];

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  Future<void> _loadSports() async {
    final useCase = sl<GetSportsUseCase>();
    final result = await useCase();
    result.fold(
      (failure) {
        setState(() {
          _isLoadingSports = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar deportes: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (sports) {
        setState(() {
          _sports = sports;
          if (_sports.isNotEmpty) {
            _selectedSportId = _sports.first.id;
          }
          _isLoadingSports = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePickerUtils.pickImageFromGallery();
    if (file != null) {
      setState(() => _imageFile = file);
    }
  }

  Future<String?> _uploadLogo() async {
    if (_imageFile == null) return null;

    try {
      final storageService = sl<FirebaseStorageService>();
      final path = 'team_logos/logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storageService.uploadFile(file: _imageFile!, path: path);
      return url;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
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

    if (_selectedSportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un deporte.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? logoUrl = await _uploadLogo();

      final createTeamUseCase = sl<CreateTeamUseCase>();

      final result = await createTeamUseCase(
        name: _nameController.text.trim(),
        sportId: _selectedSportId!,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Crear Nuevo Equipo',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
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
                  MatchDayImagePicker(
                    imageFile: _imageFile,
                    onPickImage: _pickImage,
                    placeholder: Icons.camera_alt_outlined,
                    label: 'Subir Logo del Equipo',
                    size: 120,
                  ),

                  const SizedBox(height: 24),

                  // Nombre del Equipo
                  Text(
                    'Nombre del Equipo',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Ingresa el nombre del equipo',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seleccionar Deporte
                  Text(
                    'Seleccionar Deporte',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingSports
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedSportId,
                              dropdownColor: colorScheme.surface,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              isExpanded: true,
                              style: TextStyle(color: colorScheme.onSurface),
                              items: _sports.map((sport) {
                                return DropdownMenuItem<int>(
                                  value: sport.id,
                                  child: Text(sport.name),
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
                  Text(
                    'Descripción Corta / Lema',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Cuéntale a otros jugadores sobre tu equipo...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
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
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Permite que otros jugadores vean que buscas miembros',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isRecruiting,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: colorScheme.outlineVariant,
                          onChanged: (val) {
                            setState(() => _isRecruiting = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Máximo Miembros
                  Text(
                    'Tamaño Máximo del Equipo',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _maxMembersController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Ej. 11 para Fútbol',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomSheet: Container(
        color: colorScheme.surface,
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
