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

  Future<void> requestJoinTeam(int teamId) async {
    try {
      // Basado en tu API Spec: 2.5 Solicitar Unirse (Manual)
      await networkRobot.post('/teams/$teamId/join');

    } catch (e) {
      throw Exception('Error al enviar la solicitud al capitán');
    }
  }
}
