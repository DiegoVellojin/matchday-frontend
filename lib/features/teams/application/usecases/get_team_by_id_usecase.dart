import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_teams_repository.dart';

class GetTeamByIdUseCase {
  final ITeamsRepository repository;
  GetTeamByIdUseCase(this.repository);

  Future<Either<Failure, TeamEntity>> call(int teamId) async {
    return await repository.getTeamById(teamId);
  }
}
