import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la marca MatchDay.
/// Define todos los tokens de color requeridos por [AppTheme].
class AppColors {
  // Colores principales de la marca MatchDay
  static const Color primary = Color(0xFF39CEA5); // Tu verde neón
  
  // Fondos y superficies
  static const Color background = Color(0xFF151515); // Fondo principal oscuro
  static const Color surface = Color(0xFF1E1E1E); // Tarjetas, TextFields, etc.
  
  // Elementos UI y Bordes
  static const Color border = Color(0xFF2A2A2A); // Divisores y bordes sutiles
  
  // Tipografía
  static const Color textMain = Colors.white; // Texto principal
  static const Color textMuted = Color(0xFF9CA3AF); // Texto secundario o inactivo
  static const Color textHint = Color(0xFF4A4A4A); // Placeholders
  
  // Estados
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orangeAccent;
}