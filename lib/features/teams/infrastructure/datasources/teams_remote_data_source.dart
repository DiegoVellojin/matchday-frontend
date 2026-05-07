import '../../../../core/network/network_robot.dart';
import '../../../../core/error/api_error_handler.dart';
import '../models/team_model.dart';
import '../models/sport_model.dart';

class TeamsRemoteDataSource {
  final NetworkRobot networkRobot;

  TeamsRemoteDataSource({required this.networkRobot});

  Future<List<SportModel>> getSports() async {
    try {
      final response = await networkRobot.get('/catalogs/sports');
      final List<dynamic> data = response.data;

      return data.map((json) => SportModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener la lista de deportes');
    }
  }

  Future<List<TeamModel>> getDiscoverableTeams() async {
    try {
      final response = await networkRobot.get('/teams');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener los equipos del servidor');
    }
  }

  Future<List<TeamModel>> getMyTeams() async {
    try {
      final response = await networkRobot.get('/teams/me');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener tus equipos');
    }
  }

  Future<TeamModel> getTeamById(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId');
      return TeamModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener los detalles del equipo');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId/members');
      final List<dynamic> data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener los miembros del equipo');
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
      throw ApiErrorHandler.handle(e, 'Error al enviar la solicitud al capitán');
    }
  }

  Future<void> respondToJoinRequest(int teamId, int userId, bool accept) async {
    try {
      await networkRobot.put(
        '/teams/$teamId/requests/$userId',
        data: {'accept': accept},
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al procesar la solicitud');
    }
  }

  Future<void> createTeam({
    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
    String? chatUrl,
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
          'url_chat_equipo': chatUrl,
        },
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al crear el equipo en el servidor');
    }
  }

  Future<void> updateTeam({
    required int teamId,
    String? name,
    String? logoUrl,
    String? description,
    bool? isRecruiting,
    int? maxMembers,
    String? chatUrl,
    int? sportId,
  }) async {
    try {
      await networkRobot.put(
        '/teams/$teamId',
        data: {
          'nombre_equipo': name,
          'url_logo_equipo': logoUrl,
          'descripcion_equipo': description,
          'esta_reclutando': isRecruiting,
          'max_miembros': maxMembers,
          'url_chat_equipo': chatUrl,
          'fk_id_deporte': sportId,
        }..removeWhere((_, v) => v == null),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al actualizar el equipo');
    }
  }

  Future<void> deleteTeam(int teamId) async {
    try {
      await networkRobot.delete('/teams/$teamId');
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al eliminar el equipo');
    }
  }

  Future<void> transferCaptain({
    required int teamId,
    required int newCaptainId,
  }) async {
    try {
      await networkRobot.put('/teams/$teamId/transfer-captain/$newCaptainId');
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al transferir la capitanía');
    }
  }

  Future<void> leaveTeam(int teamId) async {
    try {
      await networkRobot.delete('/teams/$teamId/leave');
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al salir del equipo');
    }
  }

  Future<void> kickMember({required int teamId, required int userId}) async {
    try {
      await networkRobot.delete('/teams/$teamId/members/$userId');
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al expulsar al miembro');
    }
  }
}
