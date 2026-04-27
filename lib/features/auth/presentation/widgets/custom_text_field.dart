import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final VoidCallback? onForgotPasswordTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.onForgotPasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    // Averiguamos en qué modo estamos para ajustar sutilezas como los bordes y placeholders
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Mostramos el botón de "Olvidaste tu contraseña" solo si nos pasan la función
            if (isPassword && onForgotPasswordTap != null)
              GestureDetector(
                onTap: onForgotPasswordTap,
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          // El color del texto que escribe el usuario se adapta al modo
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF4A4A4A) : Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade500,
            ),
            filled: true,
            // El fondo cambia de un gris oscuro (Dark) a blanco (Light)
            fillColor: colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              // El borde inactivo cambia de un gris muy oscuro a un gris clarito
              borderSide: BorderSide(
                color: isDark ? AppColors.border : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              // El borde activo siempre es de tu verde de marca
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
