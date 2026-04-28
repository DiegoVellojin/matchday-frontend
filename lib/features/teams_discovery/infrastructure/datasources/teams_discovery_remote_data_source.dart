import 'package:dio/dio.dart';
import '../../../../core/network/network_robot.dart';
import '../models/team_model.dart';
import '../models/sport_model.dart';

class TeamsDiscoveryRemoteDataSource {
  final NetworkRobot networkRobot;

  TeamsDiscoveryRemoteDataSource({required this.networkRobot});

  Future<List<SportModel>> getSports() async {
    try {
      final response = await networkRobot.get('/sports');
      final List<dynamic> data = response.data;
      return data.map((json) => SportModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, 'Error al obtener la lista de deportes');
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

  Future<List<TeamModel>> getDiscoverableTeams() async {
    try {
      final response = await networkRobot.get('/teams');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, 'Error al obtener los equipos del servidor');
    }
  }

  Future<TeamModel> getTeamById(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId');
      return TeamModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, 'Error al obtener los detalles del equipo');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId/members');
      final List<dynamic> data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw _handleError(e, 'Error al obtener los miembros del equipo');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId/requests');
      final List<dynamic> data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      // Si el backend da 403 porque no somos el capitán, devolvemos vacío en vez de romper la UI
      return [];
    }
  }

  Future<void> requestJoinTeam(int teamId) async {
    try {
      await networkRobot.post('/teams/$teamId/join');
    } catch (e) {
      throw _handleError(e, 'Error al enviar la solicitud al capitán');
    }
  }

  Future<void> respondToJoinRequest(int teamId, int userId, bool accept) async {
    try {
      await networkRobot.put('/teams/$teamId/requests/$userId', data: {'accept': accept});
    } catch (e) {
      throw _handleError(e, 'Error al procesar la solicitud');
    }
  }


  Future<void> createTeam({
    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
  }) async {
    try {
      await networkRobot.post(
        '/teams/',
        data: {
          'nombre_equipo': name,
          'fk_id_deporte': sportId,
          'url_logo_equipo': logoUrl ?? '',
          'descripcion_equipo': description,
          'esta_reclutando': isRecruiting,
          'max_miembros': maxMembers,
        },
      );
    } catch (e) {
      throw _handleError(e, 'Error al crear el equipo en el servidor');
    }
  }
}


