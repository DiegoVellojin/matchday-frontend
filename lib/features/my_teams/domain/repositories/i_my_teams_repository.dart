import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/my_team_entity.dart';

/// Contrato (Interface) que define las operaciones permitidas para Mis Equipos.
abstract class IMyTeamsRepository {
  /// Obtiene los equipos del usuario actual.
  Future<Either<Failure, List<MyTeamEntity>>> getMyTeams();

  /// Expulsa a un miembro del equipo (Solo Capitán).
  Future<Either<Failure, Unit>> kickMember({required int teamId, required int userId});
}
