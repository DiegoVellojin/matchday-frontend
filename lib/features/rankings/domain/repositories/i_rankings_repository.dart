import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/leaderboard_entry_entity.dart';
import '../entities/review_entity.dart';

abstract class IRankingsRepository {
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getTeamLeaderboard({
    int? sportId,
    String period = 'all',
  });

  Future<Either<Failure, List<ReviewEntity>>> getEvaluations({
    required int targetId,
    required bool isTeam,
  });
}
