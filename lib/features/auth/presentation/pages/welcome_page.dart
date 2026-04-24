import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/widgets/theme_toggle_button.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Ajustamos los tiempos para que sea más veloz y reactiva
  static const _mainDuration = Duration(milliseconds: 1000); // Antes 1500
  static const _trophyScaleDuration = Duration(milliseconds: 800); // Antes 1200

  bool _isGreenScreen = true;
  double _trophyScale = 0.01;
  bool _showUI = false;
  Alignment _logoAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProAnimation();
    });
  }

  void _startProAnimation() async {
    // 1. Pausa súper corta, solo para que el verde impacte al abrir
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 2. EXPLOSIÓN DEL TROFEO más rápida
    if (mounted) {
      setState(() {
        _trophyScale = 4.0; 
      });
    }

    // Esperamos que termine de crecer y le damos un respiro muy breve
    await Future.delayed(const Duration(milliseconds: 1000));

    // 3. ZUMBIDO Y ENCOGIMIENTO (A la velocidad perfecta)
    if (mounted) {
      HapticFeedback.heavyImpact(); 
      setState(() {
        _isGreenScreen = false;
        _trophyScale = 1.0; 
        _logoAlignment = const Alignment(0.0, -0.4); 
      });
    }

    // Esperamos a que el conjunto aterrice
    await Future.delayed(_mainDuration);

    // 4. Fade In ágil de los textos y botones
    if (mounted) {
      setState(() {
        _showUI = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    
    final massiveSquareSize = size.height * 1.5;

    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // CAPA 1: LA UI NORMAL
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800), // Fade in más rápido
                  opacity: _showUI ? 1.0 : 0.0,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ThemeToggleButton(),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        const SizedBox(height: 128),
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: _showUI ? 1.0 : 0.0,
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: _showUI ? 1.0 : 0.0,
                          child: Column(
                            children: [
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // CAPA 2: EL LOGO ANIMADO 
          // ==========================================
          AnimatedAlign(
            duration: _mainDuration,
            curve: Curves.easeInOutExpo, 
            alignment: _logoAlignment,
            child: AnimatedContainer(
              duration: _mainDuration,
              curve: Curves.easeInOutExpo, 
              width: _isGreenScreen ? massiveSquareSize : 128,
              height: _isGreenScreen ? massiveSquareSize : 128,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(_isGreenScreen ? 0 : 24),
                boxShadow: _isGreenScreen
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedScale(
                  duration: _trophyScaleDuration,
                  curve: Curves.easeInOutExpo, 
                  scale: _trophyScale,
                  child: const SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                  ),
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