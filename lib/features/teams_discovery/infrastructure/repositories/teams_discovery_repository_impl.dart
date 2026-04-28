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

  @override
  Future<Either<Failure, void>> respondToJoinRequest(int teamId, int userId, bool accept) async {
    try {
      await remoteDataSource.respondToJoinRequest(teamId, userId, accept);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }


  @override
  Future<Either<Failure, TeamEntity>> getTeamById(int teamId) async {
    try {
      final team = await remoteDataSource.getTeamById(teamId);
      return Right(team);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeamMembers(int teamId) async {
    try {
      final members = await remoteDataSource.getTeamMembers(teamId);
      return Right(members);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingRequests(int teamId) async {
    try {
      final requests = await remoteDataSource.getPendingRequests(teamId);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> createTeam({

    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
  }) async {
    try {
      await remoteDataSource.createTeam(
        name: name,
        sportId: sportId,
        logoUrl: logoUrl,
        description: description,
        isRecruiting: isRecruiting,
        maxMembers: maxMembers,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

