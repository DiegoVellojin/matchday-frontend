import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget reutilizable para la selección y previsualización de imágenes (fotos de perfil, logos, etc.).
/// 
/// Gestiona la visualización de una imagen local ([imageFile]) o remota ([imageUrl]),
/// mostrando un marcador de posición si ninguna está disponible.
class MatchDayImagePicker extends StatelessWidget {
  /// Archivo seleccionado localmente.
  final File? imageFile;
  
  /// URL de la imagen ya persistida en el servidor.
  final String? imageUrl;
  
  /// Acción a ejecutar cuando el usuario presiona el botón de cambio.
  final VoidCallback onPickImage;
  
  /// Texto del botón de acción.
  final String label;
  
  /// Tamaño (diámetro) del contenedor circular.
  final double size;
  
  /// Icono (IconData) o Emoji (String) a mostrar si no hay imagen disponible.
  final dynamic placeholder;


  const MatchDayImagePicker({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPickImage,
    this.label = 'Cambiar foto',
    this.size = 100,
    this.placeholder = '⚽',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: _buildImageContent(),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onPickImage,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    }
    
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: placeholder is IconData
          ? Icon(
              placeholder as IconData,
              size: size * 0.48,
              color: AppColors.primary,
            )
          : Text(
              placeholder is String && placeholder.length < 4
                  ? placeholder
                  : '👤',
              style: TextStyle(fontSize: size * 0.48),
            ),
    );
  }

}
