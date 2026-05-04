import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

class GetTeamMembersUseCase {
  final ITeamsRepository repository;
  GetTeamMembersUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(int teamId) async {
    return await repository.getTeamMembers(teamId);
  }
}
