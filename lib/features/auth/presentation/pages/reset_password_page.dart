import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widgets/theme_toggle_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';

class ResetPasswordPage extends StatelessWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  final String token;
  const _ResetPasswordView({required this.token});

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Contraseña actualizada con éxito!'), backgroundColor: AppColors.primary),
          );
          context.go('/iniciar-sesion');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          body: Stack(
            children: [
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.1)),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop()),
                          const ThemeToggleButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: const Icon(Icons.lock_reset_rounded, size: 40, color: Colors.black),
                            ).animate().fadeIn(duration: 600.ms).scale(),
                            
                            const SizedBox(height: 32),
                            const Text('Nueva contraseña', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'Crea una contraseña segura de al menos 8 caracteres para proteger tu cuenta.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, height: 1.5),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            
                            const SizedBox(height: 48),
                            
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 15))],
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    label: 'NUEVA CONTRASEÑA',
                                    hint: 'Mín. 8 caracteres',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    controller: _passwordController,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    label: 'CONFIRMAR CONTRASEÑA',
                                    hint: 'Repite la clave',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    controller: _confirmPasswordController,
                                  ),
                                  const SizedBox(height: 32),
                                  AnimatedBouncingButton(
                                    onTap: isLoading ? null : () {
                                      if (_passwordController.text != _confirmPasswordController.text) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: AppColors.error));
                                        return;
                                      }
                                      if (_passwordController.text.length < 8) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mínimo 8 caracteres'), backgroundColor: AppColors.error));
                                        return;
                                      }
                                      context.read<AuthBloc>().add(ResetPasswordSubmitted(token: widget.token, newPassword: _passwordController.text));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                            : const Text('ACTUALIZAR CONTRASEÑA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
