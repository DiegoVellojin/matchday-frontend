import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/firebase_storage_service.dart';
import '../../../../core/widgets/matchday_image_picker.dart';
import '../../../../core/utils/image_picker_utils.dart';
import '../../domain/entities/team_entity.dart';
import '../../application/usecases/get_sports_usecase.dart';
import '../../domain/entities/sport_entity.dart';
import '../../application/usecases/update_team_usecase.dart';
import '../../application/usecases/delete_team_usecase.dart';
import '../../application/usecases/transfer_captain_usecase.dart';
import '../../application/usecases/leave_team_usecase.dart';
import '../../application/usecases/kick_member_usecase.dart' as discovery_kick;
import '../../application/usecases/get_team_members_usecase.dart';
import '../widgets/team_settings_skeleton.dart';

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
  late TextEditingController _chatUrlController;
  late bool _isRecruiting;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _imageFile;
  String? _currentLogoUrl;
  List<Map<String, dynamic>> _members = [];
  List<SportEntity> _sports = [];
  int? _selectedSportId;
  bool _isInitialLoading = true;

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
    _chatUrlController = TextEditingController(text: widget.team.chatUrl);
    _isRecruiting = widget.team.isRecruiting;
    _selectedSportId = widget.team.sportId;
    _loadMembers();
    _loadSports();
  }

  Future<void> _loadMembers() async {
    final result = await sl<GetTeamMembersUseCase>().call(widget.team.id);
    result.fold(
      (_) => null,
      (members) => setState(() {
        _members = members;
        _isInitialLoading = false;
      }),
    );
  }

  Future<void> _loadSports() async {
    final result = await sl<GetSportsUseCase>().call();
    result.fold((_) => null, (sports) {
      setState(() {
        _sports = sports;
        if (_selectedSportId == null) {
          final currentSport = _sports
              .where((s) => s.name == widget.team.sportName)
              .firstOrNull;
          if (currentSport != null) _selectedSportId = currentSport.id;
        }
      });
    });
  }

  bool get isCaptain => widget.team.captainId == widget.currentUserId;

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
          'team_logos/logo_${widget.team.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await storageService.uploadFile(file: _imageFile!, path: path);
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isInitialLoading) return const Scaffold(body: TeamSettingsSkeleton());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          isCaptain ? 'Gestión de Equipo' : 'Detalles del Equipo',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (isCaptain)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: (_isLoading || _isUploadingImage)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                onPressed: (_isLoading || _isUploadingImage)
                    ? null
                    : _saveChanges,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCaptain) ...[
              _buildSectionTitle('IDENTIDAD VISUAL'),
              Center(
                child: MatchDayImagePicker(
                  imageFile: _imageFile,
                  imageUrl: _currentLogoUrl,
                  onPickImage: _pickImage,
                  placeholder: widget.team.logo.length < 4
                      ? widget.team.logo
                      : Icons.shield_rounded,
                  label: 'CAMBIAR LOGO',
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('AJUSTES PRINCIPALES'),
              _buildModernTextField(
                'NOMBRE DEL EQUIPO',
                _nameController,
                isDark,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                'DESCRIPCIÓN',
                _descriptionController,
                isDark,
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('DEPORTE Y CAPACIDAD'),
              _buildSportDropdown(isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      'MÁX. MIEMBROS',
                      _maxMembersController,
                      isDark,
                      icon: Icons.groups_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildRecruitingSwitch(isDark),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('COMUNICACIÓN'),
              _buildModernTextField(
                'URL DEL GRUPO (WHATSAPP/TELEGRAM)',
                _chatUrlController,
                isDark,
                icon: Icons.chat_bubble_outline_rounded,
              ),
              const SizedBox(height: 32),
            ] else ...[
              _buildSectionTitle('INFORMACIÓN'),
              _buildTeamHeader(isDark),
              const SizedBox(height: 32),
            ],
            _buildSectionTitle('PLANTILLA DEL EQUIPO'),
            _buildMembersList(isDark),
            const SizedBox(height: 40),
            if (isCaptain)
              _buildDangerZone(isDark)
            else
              _buildPlayerActions(isDark),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.primary, size: 20)
                : null,
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
          ),
        ),
      ],
    );
  }

  Widget _buildSportDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEPORTE',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSportId,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.primary,
              ),
              items: _sports
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedSportId = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecruitingSwitch(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECLUTANDO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Switch(
          value: _isRecruiting,
          onChanged: (v) => setState(() => _isRecruiting = v),
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTeamHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                _currentLogoUrl != null && _currentLogoUrl!.startsWith('http')
                ? NetworkImage(_currentLogoUrl!)
                : null,
            child:
                _currentLogoUrl == null || !_currentLogoUrl!.startsWith('http')
                ? Text(widget.team.logo, style: const TextStyle(fontSize: 24))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.team.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.team.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _members.length,
        separatorBuilder: (_, _) => Divider(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final m = _members[index];
          final mId = m['fk_id_usuario'] ?? m['id_usuario'];
          final isMe = mId == widget.currentUserId;
          final role = m['rol_equipo'] ?? 'Jugador';
          final isCap = role == 'Capitán';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundImage:
                  (m['url_foto_perfil']?.toString().startsWith('http') ?? false)
                  ? NetworkImage(m['url_foto_perfil'])
                  : null,
              child:
                  !(m['url_foto_perfil']?.toString().startsWith('http') ??
                      false)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              m['nombre_usuario'] ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              role,
              style: TextStyle(
                color: isCap ? AppColors.primary : Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: isCaptain && !isMe
                ? _buildMemberActions(mId, m['nombre_usuario'])
                : null,
          );
        },
      ),
    );
  }

  Widget _buildMemberActions(int mId, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(
            Icons.star_outline_rounded,
            color: AppColors.warning,
          ),
          onPressed: () => _confirmTransferCaptain(mId, name),
        ),
        IconButton(
          icon: const Icon(
            Icons.person_remove_rounded,
            color: Colors.redAccent,
          ),
          onPressed: () => _confirmKickMember(mId, name),
        ),
      ],
    );
  }

  Widget _buildDangerZone(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZONA DE PELIGRO',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmDeleteTeam,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ELIMINAR EQUIPO DEFINITIVAMENTE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerActions(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmLeaveTeam,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'SALIR DEL EQUIPO',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? logoUrl = _currentLogoUrl;
    if (_imageFile != null) {
      final uploadedUrl = await _uploadImage();
      if (uploadedUrl != null) logoUrl = uploadedUrl;
    }
    final result = await sl<UpdateTeamUseCase>().call(
      teamId: widget.team.id,
      name: _nameController.text,
      description: _descriptionController.text,
      logoUrl: logoUrl,
      maxMembers: int.tryParse(_maxMembersController.text),
      isRecruiting: _isRecruiting,
      chatUrl: _chatUrlController.text.trim().isEmpty
          ? null
          : _chatUrlController.text.trim(),
      sportId: _selectedSportId,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message), backgroundColor: Colors.redAccent),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      },
    );
  }

  void _confirmTransferCaptain(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Transferir Capitanía',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          '¿Transferir capitanía a $name? Perderás el control administrativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await sl<TransferCaptainUseCase>().call(
                teamId: widget.team.id,
                newCaptainId: userId,
              );
              setState(() => _isLoading = false);
              if (!mounted) return;
              res.fold((f) => null, (_) => Navigator.pop(context, true));
            },
            child: const Text(
              'TRANSFERIR',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmKickMember(int userId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Expulsar Miembro',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('¿Expulsar a $name del equipo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await sl<discovery_kick.KickMemberUseCase>().call(
                teamId: widget.team.id,
                userId: userId,
              );
              setState(() => _isLoading = false);
              if (!mounted) return;
              res.fold((f) => null, (_) => _loadMembers());
            },
            child: const Text(
              'EXPULSAR',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Eliminar Equipo',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Esta acción es permanente e irreversible. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await sl<DeleteTeamUseCase>().call(widget.team.id);
              if (!mounted) return;
              res.fold((f) => null, (_) => Navigator.pop(context, true));
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveTeam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Salir del Equipo',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          '¿Estás seguro de que quieres abandonar este equipo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await sl<LeaveTeamUseCase>().call(widget.team.id);
              if (!mounted) return;
              res.fold((f) => null, (_) => Navigator.pop(context, true));
            },
            child: const Text(
              'SALIR',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
