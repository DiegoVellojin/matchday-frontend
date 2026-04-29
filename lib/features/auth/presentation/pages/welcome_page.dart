import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/widgets/theme_toggle_button.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // UI Content
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ThemeToggleButton(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        const SizedBox(height: 128),
                        Text(
                          'MatchDay',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Juega. Compite. Domina.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        _buildButton(
                          text: 'Iniciar Sesión',
                          onPressed: () => context.push('/iniciar-sesion'),
                          isPrimary: true,
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          text: 'Crear Cuenta',
                          onPressed: () => context.push('/crear-cuenta'),
                          isPrimary: false,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Static Logo
          Align(
            alignment: const Alignment(0.0, -0.4),
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
    );
  }
}