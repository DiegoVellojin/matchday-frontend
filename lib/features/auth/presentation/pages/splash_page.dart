import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isServerReady = false;
  String _statusMessage = 'Preparando el estadio...';
  
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // 1. Iniciar la espera del servidor
    await _checkServerHealth();
    
    // 2. Una vez el servidor esté listo, verificar persistencia
    if (mounted) {
      _checkAuthentication();
    }
  }

  Future<void> _checkServerHealth() async {
    const healthUrl = 'https://matchday-backend-3qot.onrender.com/';
    final dio = Dio();
    bool isReady = false;
    int attempts = 0;

    while (!isReady) {
      try {
        attempts++;
        if (attempts > 1) {
          setState(() => _statusMessage = 'Despertando el servidor (Render puede tardar un poco)...');
        }

        final response = await dio.get(healthUrl).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          isReady = true;
          if (mounted) {
            setState(() {
              _isServerReady = true;
              _statusMessage = '¡Listo para el partido!';
            });
          }
        }
      } catch (e) {
        // Ignorar errores y reintentar
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> _checkAuthentication() async {
    // Pequeña pausa para que se vea el mensaje de éxito
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    final hasToken = await sl<SecureStorageService>().hasToken();
    if (!mounted) return;
    
    if (hasToken) {
      context.go('/hub');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              const Color(0xFF151515),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculos decorativos de fondo
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animado
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.black,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: AppColors.primary.withValues(alpha: 0.4))
                .shake(hz: 2, curve: Curves.easeInOutCubic)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds,
                  curve: Curves.easeInOut,
                ).then(),

                const SizedBox(height: 48),

                // Título
                Text(
                  'MATCHDAY',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 12),

                // Eslogan
                Text(
                  'EL ESTADIO EN TUS MANOS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 80),

                // Indicador de estado
                Column(
                  children: [
                    if (!_isServerReady)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ).animate().fadeIn(),
                    
                    if (_isServerReady)
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 40,
                      ).animate().scale().fadeIn(),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ).animate(key: ValueKey(_statusMessage)).fadeIn().slideY(begin: 0.2, end: 0),
                  ],
                ),
              ],
            ),

            // Versión
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
