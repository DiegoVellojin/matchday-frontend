import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

/// Caso de uso para que un usuario se retire voluntariamente de un equipo.
class LeaveTeamUseCase {
  final ITeamsRepository repository;

  LeaveTeamUseCase(this.repository);

  /// Elimina la membresía del usuario actual en el equipo [teamId].
  Future<Either<Failure, void>> call(int teamId) {
    return repository.leaveTeam(teamId);
  }
}
