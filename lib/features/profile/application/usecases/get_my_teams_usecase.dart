import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams_discovery/domain/entities/team_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';

class GetMyTeamsUseCase {
  final IProfileRepository repository;

  GetMyTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return await repository.getMyTeams();
  }
}
