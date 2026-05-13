import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/leaderboard_entry_entity.dart';

abstract class IRankingsRepository {
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getTeamLeaderboard({
    int? sportId,
    String period = 'all',
  });
}
