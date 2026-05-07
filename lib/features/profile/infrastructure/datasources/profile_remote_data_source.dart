import 'package:dio/dio.dart';
import '../../../../core/network/network_robot.dart';
import '../../../teams/infrastructure/models/team_model.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  final NetworkRobot networkRobot;

  ProfileRemoteDataSource({required this.networkRobot});

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await networkRobot.get('/users/me');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, 'Error al obtener el perfil');
    }
  }

  Future<List<TeamModel>> getMyTeams() async {
    try {
      final response = await networkRobot.get('/teams/me');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, 'Error al obtener mis equipos');
    }
  }

  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? password,
  }) async {
    try {
      final response = await networkRobot.put(
        '/users/me',
        data: {
          'nombre_usuario': ?name,
          'telefono_usuario': ?phone,
          'url_foto_perfil': ?photoUrl,
          'password': ?password,
        },
      );
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, 'Error al actualizar el perfil');
    }
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
