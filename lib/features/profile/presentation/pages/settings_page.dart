import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.go('/welcome');
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.background : Colors.grey[50],
        body: CustomScrollView(
        slivers: [
          // Header Estilo Premium
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Configuración',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('CUENTA'),
                  _buildSettingsGroup([
                    _SettingsItem(
                      icon: Icons.person_outline,
                      title: 'Editar Perfil',
                      subtitle: 'Nombre, foto, posición',
                      color: AppColors.primary,
                      onTap: () {
                        final state = context.read<ProfileBloc>().state;
                        if (state is ProfileLoaded) {
                          context.push('/editar-perfil', extra: {'profile': state.profile});
                        }
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.credit_card_outlined,
                      title: 'Gestión de Pagos',
                      subtitle: 'Gestionar pagos y comprobantes',
                      color: Colors.orange,
                      onTap: () => context.push('/payment-management'),
                    ),
                    _SettingsItem(
                      icon: Icons.groups_outlined,
                      title: 'Mis Equipos',
                      subtitle: 'Gestionar equipos y membresías',
                      color: Colors.blue,
                      onTap: () => context.push('/hub'), // O navegación específica
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle('PREFERENCIAS'),
                  _buildSettingsGroup([
                    _SettingsItem(
                      icon: Icons.palette_outlined,
                      title: 'Tema Oscuro',
                      subtitle: isDark ? 'Activado' : 'Desactivado',
                      color: Colors.purple,
                      trailing: _ToggleSwitch(
                        value: isDark,
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(ToggleThemeEvent());
                        },
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle('SOPORTE'),
                  _buildSettingsGroup([
                    _SettingsItem(
                      icon: Icons.help_outline,
                      title: 'Centro de Ayuda',
                      subtitle: 'Preguntas frecuentes y tutoriales',
                      color: Colors.yellow[700]!,
                      onTap: () => _launchURL('https://matchday.app/help'),
                    ),
                    _SettingsItem(
                      icon: Icons.description_outlined,
                      title: 'Términos y Condiciones',
                      subtitle: 'Políticas de uso',
                      color: Colors.grey,
                      onTap: () => _launchURL('https://matchday.app/terms'),
                    ),
                    _SettingsItem(
                      icon: Icons.security_outlined,
                      title: 'Política de Privacidad',
                      subtitle: 'Cómo usamos tus datos',
                      color: Colors.green,
                      onTap: () => _launchURL('https://matchday.app/privacy'),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  // App Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.border : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Versión de la aplicación', '1.0.0'),
                        const Divider(height: 24),
                        _buildInfoRow('Última actualización', '12 Mayo 2026'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Botón Cerrar Sesión
                  AnimatedBouncingButton(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'MatchDay © 2026',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hecho con ⚽ para la comunidad deportiva',
                          style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.border : Colors.grey.shade200),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(LogoutEvent());
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: 300.ms,
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12),
        ),
        child: AnimatedAlign(
          duration: 300.ms,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
