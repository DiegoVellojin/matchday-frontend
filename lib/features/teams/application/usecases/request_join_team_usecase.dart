import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

class RequestJoinTeamUseCase {
  final ITeamsRepository repository;
  RequestJoinTeamUseCase(this.repository);

  Future<Either<Failure, void>> call(int teamId) async {
    return await repository.requestJoinTeam(teamId);
  }
}
