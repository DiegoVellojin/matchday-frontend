import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

class RespondToJoinRequestUseCase {
  final ITeamsDiscoveryRepository repository;
  RespondToJoinRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(int teamId, int userId, bool accept) async {
    return await repository.respondToJoinRequest(teamId, userId, accept);
  }
}
