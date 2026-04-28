import '../../../../core/network/network_robot.dart';
import '../models/team_model.dart';

class TeamsDiscoveryRemoteDataSource {
  final NetworkRobot networkRobot;

  TeamsDiscoveryRemoteDataSource({required this.networkRobot});

  Future<List<TeamModel>> getDiscoverableTeams() async {
    try {
      // Usamos el endpoint REST estándar para listar equipos
      final response = await networkRobot.get('/teams');
      final List<dynamic> data = response.data;
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los equipos del servidor');
    }
  }

  Future<TeamModel> getTeamById(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId');
      return TeamModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener los detalles del equipo');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    try {
      final response = await networkRobot.get('/teams/$teamId/members');
      final List<dynamic> data = response.data;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener los miembros del equipo');
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
      // Basado en tu API Spec: 2.5 Solicitar Unirse (Manual)
      await networkRobot.post('/teams/$teamId/join');
    } catch (e) {
      throw Exception('Error al enviar la solicitud al capitán');
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
      throw Exception('Error al crear el equipo en el servidor');
    }
  }
}

