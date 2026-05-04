import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

/// Caso de uso para expulsar a un miembro de un equipo.
class KickMemberUseCase {
  final ITeamsRepository repository;

  KickMemberUseCase(this.repository);

  /// Remueve al usuario [userId] del equipo [teamId]. Solo ejecutable por el Capitán.
  Future<Either<Failure, void>> call({required int teamId, required int userId}) {
    return repository.kickMember(teamId: teamId, userId: userId);
  }
}
