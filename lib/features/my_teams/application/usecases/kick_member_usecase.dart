import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_my_teams_repository.dart';

/// Caso de Uso para expulsar a un miembro de un equipo.
class KickMemberUseCase {
  final IMyTeamsRepository repository;

  const KickMemberUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required int teamId, required int userId}) async {
    return await repository.kickMember(teamId: teamId, userId: userId);
  }
}
