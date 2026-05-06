import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Un botón que se encoge al ser presionado y rebota al soltarlo.
/// Proporciona un feedback táctil premium.
class AnimatedBouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const AnimatedBouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedBouncingButton> createState() => _AnimatedBouncingButtonState();
}

class _AnimatedBouncingButtonState extends State<AnimatedBouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Extensión para aplicar efectos de brillo/pulso fácilmente.
extension AnimatedGlow on Widget {
  Widget withPulseGlow({
    required Color color,
    bool enabled = true,
  }) {
    if (!enabled) return this;
    
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).custom(
      duration: 1.5.seconds,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3 * value),
              blurRadius: 15 * value,
              spreadRadius: 2 * value,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
