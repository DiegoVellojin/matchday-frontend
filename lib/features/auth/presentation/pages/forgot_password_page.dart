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

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          body: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
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
                              child: const Icon(Icons.lock_open_rounded, size: 40, color: Colors.black),
                            ).animate().fadeIn(duration: 600.ms).scale(),
                            
                            const SizedBox(height: 32),
                            const Text(
                              '¿OLVIDASTE TU CLAVE?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No te preocupes, nos pasa a los mejores. Ingresa tu correo y te enviaremos el enlace de rescate.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            
                            const SizedBox(height: 48),
                            
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: isDark 
                                      ? Colors.white.withValues(alpha: 0.1) 
                                      : Colors.black.withValues(alpha: 0.05)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20)
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    label: 'CORREO ELECTRÓNICO',
                                    hint: 'tu@email.com',
                                    icon: Icons.alternate_email_rounded,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 32),
                                  AnimatedBouncingButton(
                                    onTap: isLoading ? null : () {
                                      if (_emailController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Por favor, ingresa tu correo'), backgroundColor: AppColors.error)
                                        );
                                        return;
                                      }
                                      context.read<AuthBloc>().add(ForgotPasswordRequested(email: _emailController.text.trim()));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, Color(0xFFFFD700)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8)
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                                            : const Text(
                                                'ENVIAR INSTRUCCIONES',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.5,
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
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
