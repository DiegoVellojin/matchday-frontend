import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

class RequestJoinTeamUseCase {
  final ITeamsDiscoveryRepository repository;
  RequestJoinTeamUseCase(this.repository);

  Future<Either<Failure, void>> call(int teamId) async {
    return await repository.requestJoinTeam(teamId);
  }
}
