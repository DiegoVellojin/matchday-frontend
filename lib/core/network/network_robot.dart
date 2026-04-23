import 'package:dio/dio.dart';

class NetworkRobot {
  final Dio _dio;

  NetworkRobot(this._dio) {
    // Configuraciones maestras de tu backend FastAPI
    // Nota: Si usas el emulador de Android para probar un localhost, la IP es 10.0.2.2
    _dio.options.baseUrl = 'http://10.0.2.2:8000/api/v1'; 
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Interceptores: El "punto de control" de todas las llamadas
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: En el futuro leeremos el token del SecureStorage y lo inyectaremos aquí
          // options.headers['Authorization'] = 'Bearer $tuToken';
          
          print('🌐 PETICIÓN [${options.method}] => RUTA: ${options.path}');
          return handler.next(options); 
        },
        onResponse: (response, handler) {
          print('✅ RESPUESTA [${response.statusCode}] => RUTA: ${response.requestOptions.path}');
          return handler.next(response); 
        },
        onError: (DioException e, handler) {
          print('❌ ERROR [${e.response?.statusCode}] => RUTA: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  // Métodos que los repositorios usarán para comunicarse
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}