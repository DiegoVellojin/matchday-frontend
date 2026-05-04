import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clase que define y centraliza la configuración de temas (Claro y Oscuro) 
/// de Material Design para toda la aplicación MatchDay.
class AppTheme {
  /// Retorna el tema oscuro predeterminado de la aplicación.
  /// 
  /// Configura el [scaffoldBackgroundColor], el [colorScheme] y el tema 
  /// de botones utilizando la paleta de colores oficial.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface, // Para tarjetas y TextFields
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      useMaterial3: true,
    );
  }

  /// Retorna el tema claro de la aplicación.
  /// 
  /// Ideal para entornos con alta iluminación. Mantiene el verde principal 
  /// pero ajusta los fondos y contrastes de superficie.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Gris muy clarito
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: Colors.white, // Cajas blancas en modo claro
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black, // El texto sigue siendo negro en el botón verde
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      useMaterial3: true,
    );
  }
}