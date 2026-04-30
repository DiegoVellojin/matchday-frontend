import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Servicio encargado de la gestión de archivos en la nube mediante Firebase Storage.
/// 
/// Provee métodos para cargar archivos locales (como imágenes de perfil o logos) 
/// y obtener sus URLs públicas de descarga.
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Sube un archivo al bucket de Firebase en la ruta especificada.
  /// 
  /// [file] El objeto File local que se desea subir.
  /// [path] La ruta de destino dentro de Firebase Storage (p.ej. 'teams/logos/123.png').
  /// 
  /// Retorna la [String] con la URL pública de descarga o null si la operación falla.
  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      // Ejecuta la carga del archivo.
      final uploadTask = await ref.putFile(file);
      // Recupera la URL pública necesaria para persistir en la base de datos.
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // En caso de error, retornamos null para que la capa superior gestione el fallo.
      return null;
    }
  }
}
