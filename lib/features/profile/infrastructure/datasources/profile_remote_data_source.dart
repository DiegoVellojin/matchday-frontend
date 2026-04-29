import 'package:dio/dio.dart';
import '../../../../core/network/network_robot.dart';
import '../../../teams_discovery/infrastructure/models/team_model.dart';
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
          if (name != null) 'nombre_usuario': name,
          if (phone != null) 'telefono_usuario': phone,
          if (photoUrl != null) 'url_foto_perfil': photoUrl,
          if (password != null) 'password': password,
        },
      );
      return UserProfileModel.fromJson(response.data);

    } catch (e) {
      throw _handleError(e, 'Error al actualizar el perfil');
    }
  }

  Exception _handleError(dynamic e, String defaultMessage) {

    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          return Exception(data['detail'].toString());
        }
      }
      return Exception('$defaultMessage: ${e.message}');
    }
    return Exception(e.toString());
  }
}
