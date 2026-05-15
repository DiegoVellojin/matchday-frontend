import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_rankings_repository.dart';
import '../datasources/rankings_remote_datasource.dart';

class RankingsRepositoryImpl implements IRankingsRepository {
  final RankingsRemoteDataSource remoteDataSource;

  RankingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getTeamLeaderboard({
    int? sportId,
    String period = 'all',
  }) async {
    try {
      final leaderboard = await remoteDataSource.getTeamLeaderboard(
        sportId: sportId,
        period: period,
      );
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getEvaluations({
    required int targetId,
    required bool isTeam,
  }) async {
    try {
      final evaluations = await remoteDataSource.getEvaluations(
        targetId: targetId,
        isTeam: isTeam,
      );
      return Right(evaluations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
