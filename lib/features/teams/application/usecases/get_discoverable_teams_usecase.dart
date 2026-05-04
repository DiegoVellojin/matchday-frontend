import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_teams_repository.dart';

class GetDiscoverableTeamsUseCase {
  final ITeamsRepository repository;
  GetDiscoverableTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return await repository.getDiscoverableTeams();
  }
}
