import '../../../../core/network/network_robot.dart';
import '../../../../core/error/api_error_handler.dart';
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
      throw ApiErrorHandler.handle(e, 'Error al obtener el perfil');
    }
  }

  Future<List<TeamModel>> getMyTeams() async {
    try {
      final response = await networkRobot.get('/teams/me');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener mis equipos');
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
      throw ApiErrorHandler.handle(e, 'Error al actualizar el perfil');
    }
  }
}
