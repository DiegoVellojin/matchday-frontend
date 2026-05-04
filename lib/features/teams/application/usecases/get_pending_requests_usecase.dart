import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

class GetPendingRequestsUseCase {
  final ITeamsRepository repository;
  GetPendingRequestsUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(int teamId) async {
    return await repository.getPendingRequests(teamId);
  }
}
