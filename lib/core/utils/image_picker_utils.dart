import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Utilidades compartidas para la selección de archivos multimedia.
class ImagePickerUtils {
  /// Abre la galería del dispositivo y permite al usuario seleccionar una imagen.
  /// 
  /// Aplica compresiones por defecto (600x600, 80% calidad) para optimizar 
  /// el almacenamiento y el tiempo de carga.
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
