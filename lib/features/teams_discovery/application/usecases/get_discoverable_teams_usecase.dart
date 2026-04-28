import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

class GetDiscoverableTeamsUseCase {
  final ITeamsDiscoveryRepository repository;
  GetDiscoverableTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return await repository.getDiscoverableTeams();
  }
}
