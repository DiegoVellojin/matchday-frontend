import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/i_rankings_repository.dart';

class GetTeamLeaderboardUseCase {
  final IRankingsRepository repository;

  GetTeamLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<LeaderboardEntryEntity>>> call() {
    return repository.getTeamLeaderboard();
  }
}
