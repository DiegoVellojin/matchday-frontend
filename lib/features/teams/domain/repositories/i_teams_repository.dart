import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';
import '../entities/sport_entity.dart';

/// Contrato que define las operaciones de descubrimiento y administración de equipos.
abstract class ITeamsRepository {
  /// Recupera el catálogo completo de deportes disponibles en el sistema.
  Future<Either<Failure, List<SportEntity>>> getSports();

  /// Obtiene una lista de equipos con el flag de reclutamiento activo.
  Future<Either<Failure, List<TeamEntity>>> getDiscoverableTeams();

  /// Obtiene los equipos del usuario actual.
  Future<Either<Failure, List<TeamEntity>>> getMyTeams();

  /// Registra una intención de unión del usuario actual a un equipo específico.
  Future<Either<Failure, void>> requestJoinTeam(int teamId);

  /// Permite al capitán aprobar o denegar una solicitud de acceso al equipo.
  Future<Either<Failure, void>> respondToJoinRequest(int teamId, int userId, bool accept);

  /// Consulta la información detallada de un equipo por su ID.
  Future<Either<Failure, TeamEntity>> getTeamById(int teamId);

  /// Recupera el listado de usuarios que son miembros aceptados de un equipo.
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeamMembers(int teamId);

  /// Obtiene las solicitudes de unión que aún no han sido procesadas por el capitán.
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingRequests(int teamId);

  /// Crea un nuevo equipo persistiendo sus metadatos y configuraciones iniciales.
  Future<Either<Failure, void>> createTeam({
    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
    String? chatUrl,
  });

  /// Modifica los atributos de un equipo existente. Reservado para el Capitán.
  Future<Either<Failure, void>> updateTeam({
    required int teamId,
    String? name,
    String? logoUrl,
    String? description,
    bool? isRecruiting,
    int? maxMembers,
    String? chatUrl,
    int? sportId,
  });

  /// Elimina el equipo y todas sus relaciones de membresía. Reservado para el Capitán.
  Future<Either<Failure, void>> deleteTeam(int teamId);

  /// Cede el rol administrativo a otro miembro aceptado del equipo.
  Future<Either<Failure, void>> transferCaptain({
    required int teamId,
    required int newCaptainId,
  });

  /// Elimina la relación de membresía del usuario actual con el equipo.
  Future<Either<Failure, void>> leaveTeam(int teamId);

  /// Remueve forzosamente a un miembro del equipo. Reservado para el Capitán.
  Future<Either<Failure, void>> kickMember({
    required int teamId,
    required int userId,
  });
}
