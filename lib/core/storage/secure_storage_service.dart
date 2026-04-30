import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio encargado de la persistencia de datos sensibles en el dispositivo.
/// 
/// Gestiona el almacenamiento del token de autenticación (JWT) y preferencias 
/// de usuario como el modo de tema, utilizando cifrado de nivel de sistema operativo.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _tokenKey = 'auth_token';
  static const _themeKey = 'theme_mode';

  /// Guarda el token JWT de forma persistente.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Recupera el token JWT almacenado. Retorna null si no existe.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token del almacenamiento (Logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Verifica la existencia de un token válido.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Almacena la preferencia del modo de tema.
  Future<void> saveThemeMode(bool isDark) async {
    await _storage.write(key: _themeKey, value: isDark ? 'dark' : 'light');
  }

  /// Retorna true si el usuario ha seleccionado el modo oscuro o no tiene preferencia guardada.
  Future<bool> isDarkMode() async {
    final mode = await _storage.read(key: _themeKey);
    return mode != 'light'; // Por defecto es oscuro para MatchDay.
  }
}
