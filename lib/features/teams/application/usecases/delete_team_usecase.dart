import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

/// Caso de uso para eliminar un equipo de forma definitiva.
class DeleteTeamUseCase {
  final ITeamsRepository repository;

  DeleteTeamUseCase(this.repository);

  /// Ejecuta la eliminación del equipo identificado por [teamId].
  Future<Either<Failure, void>> call(int teamId) {
    return repository.deleteTeam(teamId);
  }
}
