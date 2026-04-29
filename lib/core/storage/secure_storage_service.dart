import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _tokenKey = 'auth_token';
  static const _themeKey = 'theme_mode';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveThemeMode(bool isDark) async {
    await _storage.write(key: _themeKey, value: isDark ? 'dark' : 'light');
  }

  Future<bool> isDarkMode() async {
    final mode = await _storage.read(key: _themeKey);
    return mode != 'light'; // Por defecto es oscuro (true)
  }
}
