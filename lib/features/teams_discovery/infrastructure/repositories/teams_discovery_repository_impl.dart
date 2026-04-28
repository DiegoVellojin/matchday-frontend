import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';
import '../datasources/teams_discovery_remote_data_source.dart';

class TeamsDiscoveryRepositoryImpl implements ITeamsDiscoveryRepository {
  final TeamsDiscoveryRemoteDataSource remoteDataSource;

  TeamsDiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TeamEntity>>> getDiscoverableTeams() async {
    try {
      final teams = await remoteDataSource.getDiscoverableTeams();
      return Right(teams);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> requestJoinTeam(int teamId) async {
    try {
      await remoteDataSource.requestJoinTeam(teamId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
