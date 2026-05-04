import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/i_rankings_repository.dart';
import '../datasources/rankings_remote_datasource.dart';

class RankingsRepositoryImpl implements IRankingsRepository {
  final RankingsRemoteDataSource remoteDataSource;

  RankingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getTeamLeaderboard() async {
    try {
      final leaderboard = await remoteDataSource.getTeamLeaderboard();
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
