import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _mainDuration = Duration(milliseconds: 1000);
  static const _trophyScaleDuration = Duration(milliseconds: 800);

  bool _isGreenScreen = true;
  double _trophyScale = 0.01;
  Alignment _logoAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProAnimation();
    });
  }

  void _startProAnimation() async {
    // 1. Pausa súper corta
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 2. EXPLOSIÓN DEL TROFEO
    if (mounted) {
      setState(() {
        _trophyScale = 4.0; 
      });
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // 3. ZUMBIDO Y ENCOGIMIENTO
    if (mounted) {
      HapticFeedback.heavyImpact(); 
      setState(() {
        _isGreenScreen = false;
        _trophyScale = 1.0; 
        _logoAlignment = const Alignment(0.0, -0.4); 
      });
    }

    // Esperamos a que termine la animación
    await Future.delayed(_mainDuration);

    // 4. Verificar persistencia (Token)
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
    final size = MediaQuery.of(context).size;
    final massiveSquareSize = size.height * 1.5;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          AnimatedAlign(
            duration: _mainDuration,
            curve: Curves.easeInOutExpo, 
            alignment: _logoAlignment,
            child: Hero(
              tag: 'app_logo_hero',
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
                            color: AppColors.primary.withValues(alpha: 0.3),
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
          ),
        ],
      ),
    );
  }
}
