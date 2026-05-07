import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Dio dio;
  bool _isInitialized = false;

  AuthRemoteDataSource({required this.dio});

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  /// 1. Flujo Google
  Future<String?> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      final String? idToken = googleUser.authentication.idToken;

      if (idToken != null) {
        debugPrint("🚀 Enviando Google Token a Render...");
        final response = await dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.authGoogle}',
          data: {"id_token": idToken},
        );
        return response.data['access_token'];
      }
      return null;
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled' || e.code.name == 'sign_in_canceled') {
        return null;
      }
      throw Exception('Fallo al autenticar con Google');
    } on DioException catch (e) {
      throw _handleError(e, 'Error al autenticar con Google');
    }
  }

  /// 2. Flujo Login
  Future<String> loginUser(String email, String password) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.authLogin}',
        data: {'email': email, 'password': password},
      );
      return response.data['access_token'];
    } on DioException catch (e) {
      throw _handleError(e, 'Credenciales inválidas');
    }
  }

  /// 3. Flujo Registro
  Future<String> registerUser(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.authRegister}',
        data: {'nombre_usuario': nombre, 'email': email, 'password': password},
      );
      return response.data['access_token'];
    } on DioException catch (e) {
      throw _handleError(e, 'Error al registrar usuario');
    }
  }

  /// 4. Flujo Solicitar Recuperación
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.authForgotPassword}',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Error al procesar la solicitud');
    }
  }

  /// 5. Flujo Restablecer Contraseña (NUEVO)
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await dio.post(
        'https://matchday-backend-3qot.onrender.com/api/v1/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Error al actualizar contraseña');
    }
  }

  /// 6. Cerrar Sesión
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.disconnect();
  }

  Exception _handleError(dynamic e, String defaultMessage) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return Exception('Estamos preparando la cancha... El servidor está despertando, por favor intenta de nuevo en unos segundos. 🏟️⚽');
      }

      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          return Exception(data['detail'].toString());
        }
      }
      return Exception('$defaultMessage. 🛠️');
    }
    return Exception(e.toString());
  }
}
