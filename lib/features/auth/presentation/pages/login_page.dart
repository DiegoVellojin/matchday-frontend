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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../../core/widgets/animated_bouncing_button.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignInWithEmailButtonPressed(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
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
        } else if (state is AuthAuthenticated) {
          context.read<ProfileBloc>().add(LoadProfileEvent());
          context.go('/hub');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
          body: Stack(
            children: [
              // Decorative Background Gradient
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: isDark ? 0.05 : 0.1),
                  ),
                ),
              ),
              
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topRight,
                              child: ThemeToggleButton(),
                            ),
                            const SizedBox(height: 20),
                            
                            // Logo & Header
                            Hero(
                              tag: 'app_logo_hero',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.emoji_events, size: 48, color: Colors.black),
                              ),
                            ).animate().fadeIn(duration: 600.ms).scale(),
                            
                            const SizedBox(height: 24),
                            
                            const Text(
                              'Bienvenido de nuevo',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Inicia sesión para continuar tu camino a la cima.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                            
                            const SizedBox(height: 48),
                            
                            // Form Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: 'CORREO ELECTRÓNICO',
                                      hint: 'tu@email.com',
                                      icon: Icons.mail_outline_rounded,
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                                    ),
                                    const SizedBox(height: 24),
                                    CustomTextField(
                                      label: 'CONTRASEÑA',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      controller: _passwordController,
                                      onForgotPasswordTap: () => context.push('/recuperar-contrasena'),
                                    ),
                                    const SizedBox(height: 32),
                                    AnimatedBouncingButton(
                                      onTap: isLoading ? null : _onLoginPressed,
                                      child: Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                                          ],
                                        ),
                                        child: Center(
                                          child: isLoading
                                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                              : const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                            
                            const SizedBox(height: 32),
                            
                            _buildDivider(isDark),
                            
                            const SizedBox(height: 32),
                            
                            GoogleSignInButton(
                              isLoading: isLoading,
                              onPressed: () => context.read<AuthBloc>().add(SignInWithGoogleButtonPressed()),
                            ).animate().fadeIn(delay: 500.ms),
                            
                            const Spacer(),
                            const SizedBox(height: 32),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('¿No tienes cuenta? ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                                GestureDetector(
                                  onTap: () => context.push('/crear-cuenta'),
                                  child: const Text('Regístrate', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 24),
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

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('O CONTINÚA CON', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
      ],
    );
  }
}
