import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widgets/theme_toggle_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  const ThemeToggleButton(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.health_and_safety_outlined, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    Text('Recuperar Contraseña', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingresa tu correo electrónico registrado y te enviaremos un enlace para restablecer tu contraseña.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 48),

                    const CustomTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', icon: Icons.mail_outline),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Enlace enviado!'), backgroundColor: AppColors.primary));
                          context.pop();
                        },
                        child: const Text('Enviar Enlace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}