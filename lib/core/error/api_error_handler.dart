import 'package:dio/dio.dart';

/// Clase utilitaria para centralizar el manejo de errores de la API.
/// 
/// Proporciona mensajes amigables y temáticos para el usuario, evitando
/// mostrar errores técnicos crudos.
class ApiErrorHandler {
  static Exception handle(dynamic e, String defaultMessage) {
    if (e is DioException) {
      // Caso específico: El servidor está despertando (Render cold start)
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return Exception('Estamos preparando la cancha... El servidor está despertando, por favor intenta de nuevo en unos segundos. 🏟️⚽');
      }

      // Caso: Error de conexión a internet
      if (e.type == DioExceptionType.connectionError) {
        return Exception('No pudimos conectar con el estadio. Revisa tu conexión a internet. 📶');
      }

      // Caso: El backend devolvió un error controlado
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          return Exception(data['detail'].toString());
        }
      }

      // Otros errores de Dio
      return Exception('$defaultMessage. 🛠️');
    }

    // Errores genéricos
    return Exception(e.toString().replaceAll('Exception: ', ''));
  }
}
