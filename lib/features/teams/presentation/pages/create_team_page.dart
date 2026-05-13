import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/image_picker_utils.dart';
import '../../../../core/widgets/matchday_image_picker.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/theme/app_colors.dart';

import '../../application/usecases/create_team_usecase.dart';
import '../../../catalogs/application/usecases/get_sports_usecase.dart'
    as cat_sports;
import '../bloc/teams_bloc.dart';
import '../bloc/teams_state.dart';
import '../../domain/entities/sport_entity.dart';
import '../../../../features/main_hub/presentation/widgets/form_skeleton.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '11');
  final _chatUrlController = TextEditingController();

  int? _selectedSportId;
  bool _isRecruiting = true;
  File? _imageFile;
  bool _isLoading = false;
  bool _isLoadingSports = true;

  List<SportEntity> _sports = [];

  @override
  void initState() {
    super.initState();

    // Optimizamos: Si ya tenemos los deportes en el TeamsBloc, los usamos de una vez
    // para evitar que el usuario vea el esqueleto de carga innecesariamente.
    final teamsState = context.read<TeamsBloc>().state;
    if (teamsState is TeamsLoaded) {
      _sports = teamsState.sports;
      if (_sports.isNotEmpty) {
        _selectedSportId = _sports.first.id;
      }
      _isLoadingSports = false;
    } else {
      _loadSports();
    }
  }

  Future<void> _loadSports() async {
    final useCase = sl<cat_sports.GetSportsUseCase>();
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
    _chatUrlController.dispose();
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
      final path =
          'team_logos/logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storageService.uploadFile(
        file: _imageFile!,
        path: path,
      );
      return url;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _createTeam() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
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
        chatUrl: _chatUrlController.text.trim().isEmpty
            ? null
            : _chatUrlController.text.trim(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoadingSports
          ? const FormSkeleton(hasImagePicker: true)
          : Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'Crear Nuevo Equipo',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        centerTitle: false,
                        titlePadding: const EdgeInsets.only(
                          left: 56,
                          bottom: 16,
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Center(
                                child: MatchDayImagePicker(
                                  imageFile: _imageFile,
                                  onPickImage: _pickImage,
                                  placeholder: Icons.add_a_photo_outlined,
                                  label: 'Logo del equipo',
                                  size: 140,
                                ),
                              ),
                              const SizedBox(height: 40),

                              _buildSectionTitle('INFORMACIÓN BÁSICA', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumTextField(
                                controller: _nameController,
                                label: 'Nombre del equipo',
                                hint: 'Ej. Los Galácticos FC',
                                icon: Icons.shield_outlined,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'El nombre es obligatorio';
                                  if (value.trim().length < 4)
                                    return 'Mínimo 4 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              _buildSectionTitle('DEPORTE', isDark),
                              const SizedBox(height: 12),
                              _buildPremiumSportSelector(isDark),
                              const SizedBox(height: 24),

                              _buildSectionTitle('DETALLES', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumTextField(
                                controller: _descriptionController,
                                label: 'Descripción / Lema',
                                hint: 'Describe la esencia de tu equipo...',
                                icon: Icons.notes_rounded,
                                isDark: isDark,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPremiumTextField(
                                      controller: _maxMembersController,
                                      label: 'Miembros máx.',
                                      hint: '11',
                                      icon: Icons.groups_outlined,
                                      isDark: isDark,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildRecruitmentToggle(isDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              _buildSectionTitle('SOCIAL', isDark),
                              const SizedBox(height: 16),
                              _buildPremiumTextField(
                                controller: _chatUrlController,
                                label: 'Link de Chat (Opcional)',
                                hint: 'Link de WhatsApp o Telegram',
                                icon: Icons.link_rounded,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomActions(isDark),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSportSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSportId,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          items: _sports.map((sport) {
            return DropdownMenuItem<int>(
              value: sport.id,
              child: Text(
                sport.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedSportId = val);
          },
        ),
      ),
    );
  }

  Widget _buildRecruitmentToggle(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reclutando',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                _isRecruiting
                    ? Icons.person_add_rounded
                    : Icons.person_add_disabled_rounded,
                color: _isRecruiting ? AppColors.primary : Colors.grey,
                size: 20,
              ),
              Switch.adaptive(
                value: _isRecruiting,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isRecruiting = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: AnimatedBouncingButton(
        onTap: _isLoading ? null : _createTeam,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'CREAR EQUIPO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
