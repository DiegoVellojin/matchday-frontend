import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/widgets/theme_toggle_button.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Replicando el setTimeout de React para el Fade-in
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón de alternar tema arriba a la derecha
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
                    // Logo and Branding con Animación
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      opacity: _opacity,
                      child: Column(
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: AppColors.primary, // Verde dinámico
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.emoji_events, size: 80, color: Colors.black),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'MatchDay',
                            // El color se adapta al modo claro (negro) u oscuro (blanco)
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Juega. Compite. Domina.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.primary, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Botones de acción
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      opacity: _opacity,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => context.push('/iniciar-sesion'),
                              // Ya no necesitamos definir los colores aquí porque el AppTheme se encarga, 
                              // pero los dejamos limpios apuntando a AppColors por si acaso.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => context.push('/crear-cuenta'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary, width: 2),
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Crear Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24), // Espacio extra inferior
                        ],
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