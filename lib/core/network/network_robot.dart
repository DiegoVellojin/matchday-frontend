import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Cliente HTTP centralizado para la comunicación con la API de MatchDay.
/// 
/// Utiliza [Dio] bajo el capó y gestiona automáticamente la inyección de 
/// tokens de autenticación en las cabeceras, así como el logging de peticiones.
class NetworkRobot {
  final Dio _dio;
  final SecureStorageService _storage;

  NetworkRobot(this._dio, this._storage) {
    // Configuración global del cliente HTTP.
    _dio.options.baseUrl = 'https://matchday-backend-3qot.onrender.com/api/v1';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Interceptores para la gestión de tokens y debugging.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inyectar el JWT si está disponible en el almacenamiento seguro.
          final token = await _storage.getToken();
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options); 
        },
        onResponse: (response, handler) {
          return handler.next(response); 
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  /// Realiza una petición GET.
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// Realiza una petición POST enviando [data] en el cuerpo.
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  /// Realiza una petición PUT para actualizar recursos.
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  /// Realiza una petición DELETE para eliminar recursos.
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}