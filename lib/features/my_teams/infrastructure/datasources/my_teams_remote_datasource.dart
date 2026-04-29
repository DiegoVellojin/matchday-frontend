import '../../../../core/network/network_robot.dart';
import '../models/my_team_model.dart';

/// Cliente API para comunicarse con el backend en el contexto de Mis Equipos.
class MyTeamsRemoteDataSource {
  final NetworkRobot networkRobot;

  const MyTeamsRemoteDataSource(this.networkRobot);

  /// Consulta `/teams/me` para obtener los equipos donde pertenece el usuario.
  Future<List<MyTeamModel>> getMyTeams() async {
    try {
      final response = await networkRobot.get('/teams/me');
      final List<dynamic> data = response.data;
      return data.map((json) => MyTeamModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los equipos desde el servidor.');
    }
  }

  /// Ejecuta `/teams/{teamId}/members/{userId}` con verbo DELETE para expulsar a un miembro.
  Future<void> kickMember({required int teamId, required int userId}) async {
    try {
      await networkRobot.delete('/teams/$teamId/members/$userId');
    } catch (e) {
      throw Exception('Error al intentar expulsar al miembro del equipo.');
    }
  }
}
