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

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos'), backgroundColor: Colors.redAccent),
        );
        return;
      }
      context.read<AuthBloc>().add(
            RegisterButtonPressed(
              name: _nameController.text.trim(),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
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
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop()),
                              const ThemeToggleButton(),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text('Crea tu cuenta', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          Text('Únete a la mayor comunidad deportiva.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15)),
                          const SizedBox(height: 40),
                          
                          GoogleSignInButton(
                            isLoading: isLoading,
                            onPressed: () => context.read<AuthBloc>().add(SignInWithGoogleButtonPressed()),
                          ).animate().fadeIn(duration: 400.ms),
                          
                          const SizedBox(height: 32),
                          _buildDivider(isDark),
                          const SizedBox(height: 32),
                          
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    label: 'NOMBRE COMPLETO',
                                    hint: 'Tu nombre',
                                    icon: Icons.person_outline_rounded,
                                    controller: _nameController,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    label: 'CORREO ELECTRÓNICO',
                                    hint: 'tu@email.com',
                                    icon: Icons.mail_outline_rounded,
                                    controller: _emailController,
                                    validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    label: 'CONTRASEÑA',
                                    hint: 'Mín. 6 caracteres',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    controller: _passwordController,
                                    validator: (v) => (v == null || v.length < 6) ? 'Muy corta' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    label: 'CONFIRMAR CONTRASEÑA',
                                    hint: 'Repite tu contraseña',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    controller: _confirmPasswordController,
                                    validator: (v) => (v != _passwordController.text) ? 'No coinciden' : null,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  GestureDetector(
                                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: _acceptedTerms ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _acceptedTerms ? AppColors.primary : (Colors.grey[400] ?? Colors.grey), width: 2),
                                          ),
                                          child: _acceptedTerms ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text('Acepto los Términos y Condiciones', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  AnimatedBouncingButton(
                                    onTap: isLoading ? null : _onRegisterPressed,
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
                                            : const Text('CREAR CUENTA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('¿Ya tienes cuenta? ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                              GestureDetector(onTap: () => context.push('/iniciar-sesion'), child: const Text('Inicia Sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ]),
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
          child: Text('O REGÍSTRATE CON', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
      ],
    );
  }
}
