import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';

abstract class ITeamsDiscoveryRepository {
  /// Obtiene la lista de todos los equipos disponibles para unirse
  Future<Either<Failure, List<TeamEntity>>> getDiscoverableTeams();

  /// Envía la solicitud manual para unirse a un equipo
  Future<Either<Failure, void>> requestJoinTeam(int teamId);

  /// Acepta o rechaza una solicitud de unión
  Future<Either<Failure, void>> respondToJoinRequest(int teamId, int userId, bool accept);

  /// Obtiene los detalles de un equipo específico
  Future<Either<Failure, TeamEntity>> getTeamById(int teamId);


  /// Obtiene los miembros reales de un equipo
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeamMembers(int teamId);

  /// Obtiene las solicitudes pendientes reales
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingRequests(int teamId);



  /// Crea un nuevo equipo con todos sus parámetros
  Future<Either<Failure, void>> createTeam({
    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
  });
}

