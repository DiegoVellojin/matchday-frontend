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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Configuración',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.1), isDark ? const Color(0xFF111827) : Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('CUENTA'),
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Editar Perfil',
                        subtitle: 'Nombre, foto y posición',
                        color: AppColors.primary,
                        onTap: () {
                          final state = context.read<ProfileBloc>().state;
                          if (state is ProfileLoaded) {
                            context.push('/editar-perfil', extra: {'profile': state.profile});
                          }
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Gestión de Pagos',
                        subtitle: 'Cuentas bancarias y pagos',
                        color: Colors.orangeAccent,
                        onTap: () => context.push('/payment-management'),
                      ),
                    ], isDark),
                    const SizedBox(height: 32),
                    _buildSectionHeader('PREFERENCIAS'),
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Modo Oscuro',
                        subtitle: isDark ? 'Activado' : 'Desactivado',
                        color: Colors.indigoAccent,
                        trailing: _ModernSwitch(
                          value: isDark,
                          onChanged: (_) => context.read<ThemeBloc>().add(ToggleThemeEvent()),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notificaciones',
                        subtitle: 'Gestionar alertas de partidos',
                        color: Colors.pinkAccent,
                        onTap: () => context.push('/notificaciones'),
                      ),
                    ], isDark),
                    const SizedBox(height: 32),
                    _buildSectionHeader('SOPORTE'),
                    _buildSettingsCard([
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Centro de Ayuda',
                        subtitle: 'Preguntas y soporte técnico',
                        color: Colors.tealAccent,
                        onTap: () => _launchURL('https://matchday.app/help'),
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Términos y Condiciones',
                        subtitle: 'Legal y políticas de uso',
                        color: Colors.blueGrey,
                        onTap: () => _launchURL('https://matchday.app/terms'),
                      ),
                    ], isDark),
                    const SizedBox(height: 48),
                    _buildLogoutButton(context),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Text('MatchDay v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Made with ❤️ for athletes', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return AnimatedBouncingButton(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 12),
            Text('CERRAR SESIÓN', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Cerrar sesión?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Tu sesión se cerrará en este dispositivo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.color, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitch({required this.value, required this.onChanged});

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
          color: value ? AppColors.primary : Colors.grey[400],
        ),
        child: AnimatedAlign(
          duration: 300.ms,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
          ),
        ),
      ),
    );
  }
}
