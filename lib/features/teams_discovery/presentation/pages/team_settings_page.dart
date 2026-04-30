import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/widgets/matchday_image_picker.dart';
import '../../../../core/utils/image_picker_utils.dart';
import '../../domain/entities/team_entity.dart';
import '../../application/usecases/update_team_usecase.dart';
import '../../application/usecases/delete_team_usecase.dart';
import '../../application/usecases/transfer_captain_usecase.dart';
import '../../application/usecases/leave_team_usecase.dart';
import '../../application/usecases/kick_member_usecase.dart' as discovery_kick;
import '../../application/usecases/get_team_members_usecase.dart';

/// Pantalla de configuración y administración del equipo.
///
/// Adapta su interfaz dinámicamente según si el usuario actual es el
/// Capitán (permite editar metadatos, gestionar miembros y eliminar equipo)
/// o un Jugador (permite ver la lista de miembros y abandonar el equipo).
class TeamSettingsPage extends StatefulWidget {
  final TeamEntity team;
  final int currentUserId;

  const TeamSettingsPage({
    super.key,
    required this.team,
    required this.currentUserId,
  });

  @override
  State<TeamSettingsPage> createState() => _TeamSettingsPageState();
}

class _TeamSettingsPageState extends State<TeamSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late TextEditingController _maxMembersController;
  late bool _isRecruiting;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _imageFile;
  String? _currentLogoUrl;
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _descriptionController = TextEditingController(
      text: widget.team.description,
    );
    _currentLogoUrl = widget.team.logo;
    _maxMembersController = TextEditingController(
      text: widget.team.maxMembers.toString(),
    );
    _isRecruiting = widget.team.isRecruiting;
    _loadMembers();
  }

  /// Recupera el listado de miembros del equipo desde la API.
  Future<void> _loadMembers() async {
    final result = await sl<GetTeamMembersUseCase>().call(widget.team.id);
    result.fold(
      (failure) => null,
      (members) => setState(() => _members = members),
    );
  }

  /// Getter semántico para determinar permisos administrativos.
  bool get isCaptain => widget.team.captainId == widget.currentUserId;

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
      final path =
          'team_logos/logo_${widget.team.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await storageService.uploadFile(
        file: _imageFile!,
        path: path,
      );
      return url;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ajustes del Equipo'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (isCaptain)
            IconButton(
              icon: (_isLoading || _isUploadingImage)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppColors.primary),
              onPressed: (_isLoading || _isUploadingImage)
                  ? null
                  : _saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCaptain) ...[
              _buildSectionTitle('Información General'),
              MatchDayImagePicker(
                imageFile: _imageFile,
                imageUrl: _currentLogoUrl,
                onPickImage: _pickImage,
                placeholder: widget.team.logo.length < 4 
                    ? widget.team.logo 
                    : Icons.camera_alt_outlined,
                label: 'Cambiar logo',
              ),

              const SizedBox(height: 24),
              _buildTextField('Nombre del Equipo', _nameController),
              const SizedBox(height: 16),
              _buildTextField(
                'Descripción',
                _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Miembros Máximos',
                      _maxMembersController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reclutando',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _isRecruiting,
                        onChanged: (val) => setState(() => _isRecruiting = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Gestión de Miembros'),
              _buildMembersList(colorScheme),
              const SizedBox(height: 32),
              _buildDangerZone(),
            ] else ...[
              _buildSectionTitle('Información del Equipo'),
              _buildTeamHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('Miembros del Equipo'),
              _buildMembersList(colorScheme),
              const SizedBox(height: 32),
              _buildPlayerActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child:
                  _currentLogoUrl != null && _currentLogoUrl!.startsWith('http')
                  ? Image.network(_currentLogoUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        widget.team.logo,
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
                  widget.team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.team.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un encabezado de sección con estilo estandarizado.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Construye un campo de texto estilizado para el formulario de edición.
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            fillColor: AppColors.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la lista visual de miembros con acciones administrativas condicionales.
  Widget _buildMembersList(ColorScheme colorScheme) {
    if (_members.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _members.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.border, height: 1),
        itemBuilder: (context, index) {
          final member = _members[index];
          final mId = member['fk_id_usuario'] ?? member['id_usuario'];
          final isMe = mId == widget.currentUserId;
          final role = member['rol_equipo'] ?? 'Jugador';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.background,
              backgroundImage:
                  member['url_foto_perfil'] != null &&
                      member['url_foto_perfil'].toString().startsWith('http')
                  ? NetworkImage(member['url_foto_perfil'])
                  : null,
              child: member['url_foto_perfil'] == null
                  ? const Icon(Icons.person, color: AppColors.textMuted)
                  : null,
            ),
            title: Text(
              member['nombre_usuario'] ?? 'Usuario',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              role,
              style: TextStyle(
                color: role == 'Capitán'
                    ? AppColors.primary
                    : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            trailing: isCaptain && !isMe
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.star_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        tooltip: 'Hacer Capitán',
                        onPressed: () => _confirmTransferCaptain(
                          mId,
                          member['nombre_usuario'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_remove_outlined,
                          color: AppColors.error,
                          size: 20,
                        ),
                        tooltip: 'Expulsar',
                        onPressed: () =>
                            _confirmKickMember(mId, member['nombre_usuario']),
                      ),
                    ],
                  )
                : null,
          );
        },
      ),
    );
  }

  /// Construye la sección de acciones destructivas para el Capitán.
  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZONA DE PELIGRO',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmDeleteTeam,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ELIMINAR EQUIPO'),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón de abandono para jugadores que no son capitanes.
  Widget _buildPlayerActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmLeaveTeam,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'SALIR DEL EQUIPO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- ACCIONES Y LÓGICA DE NEGOCIO ---

  /// Persiste los cambios realizados en el formulario de información general.
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    String? logoUrl = _currentLogoUrl;
    if (_imageFile != null) {
      final uploadedUrl = await _uploadImage();
      if (uploadedUrl != null) {
        logoUrl = uploadedUrl;
      }
    }

    final result = await sl<UpdateTeamUseCase>().call(
      teamId: widget.team.id,
      name: _nameController.text,
      description: _descriptionController.text,
      logoUrl: logoUrl,
      maxMembers: int.tryParse(_maxMembersController.text),
      isRecruiting: _isRecruiting,
    );

    setState(() => _isLoading = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${failure.message}'),
          backgroundColor: AppColors.error,
        ),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados con éxito'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      },
    );
  }

  /// Muestra un diálogo de confirmación para ceder la capitanía.
  void _confirmTransferCaptain(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transferir Capitanía'),
        content: Text(
          '¿Estás seguro de que quieres transferir la capitanía a $name? Perderás el control administrativo del equipo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final result = await sl<TransferCaptainUseCase>().call(
                teamId: widget.team.id,
                newCaptainId: userId,
              );
              setState(() => _isLoading = false);
              result.fold(
                (f) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(f.message))),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Capitanía transferida')),
                  );
                  Navigator.pop(context, true);
                },
              );
            },
            child: const Text(
              'Transferir',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para confirmar la expulsión de un miembro.
  void _confirmKickMember(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expulsar Miembro'),
        content: Text('¿Quieres expulsar a $name del equipo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final result = await sl<discovery_kick.KickMemberUseCase>().call(
                teamId: widget.team.id,
                userId: userId,
              );
              setState(() => _isLoading = false);
              result.fold(
                (f) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(f.message))),
                (_) => _loadMembers(),
              );
            },
            child: const Text(
              'Expulsar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo crítico para la eliminación total del equipo.
  void _confirmDeleteTeam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Equipo'),
        content: const Text(
          'Esta acción es irreversible. Se eliminarán todos los miembros y datos del equipo. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final result = await sl<DeleteTeamUseCase>().call(widget.team.id);
              setState(() => _isLoading = false);
              result.fold(
                (f) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(f.message))),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipo eliminado')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              );
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo para confirmar el abandono voluntario de un jugador.
  void _confirmLeaveTeam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del Equipo'),
        content: const Text(
          '¿Estás seguro de que quieres salir de este equipo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final result = await sl<LeaveTeamUseCase>().call(widget.team.id);
              setState(() => _isLoading = false);
              result.fold(
                (f) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(f.message))),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Has salido del equipo')),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              );
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }
}
