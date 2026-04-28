import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';

abstract class ITeamsDiscoveryRepository {
  /// Obtiene la lista de todos los equipos disponibles para unirse
  Future<Either<Failure, List<TeamEntity>>> getDiscoverableTeams();

  /// Envía la solicitud manual para unirse a un equipo
  Future<Either<Failure, void>> requestJoinTeam(int teamId);
}
