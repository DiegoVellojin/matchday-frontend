import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/sport_entity.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';
import '../datasources/teams_discovery_remote_data_source.dart';

class TeamsDiscoveryRepositoryImpl implements ITeamsDiscoveryRepository {
  final TeamsDiscoveryRemoteDataSource remoteDataSource;

  TeamsDiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SportEntity>>> getSports() async {
    try {
      final sports = await remoteDataSource.getSports();
      return Right(sports);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

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
    String? chatUrl,
  }) async {
    try {
      await remoteDataSource.createTeam(
        name: name,
        sportId: sportId,
        logoUrl: logoUrl,
        description: description,
        isRecruiting: isRecruiting,
        maxMembers: maxMembers,
        chatUrl: chatUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> updateTeam({
    required int teamId,
    String? name,
    String? logoUrl,
    String? description,
    bool? isRecruiting,
    int? maxMembers,
    String? chatUrl,
    int? sportId,
  }) async {
    try {
      await remoteDataSource.updateTeam(
        teamId: teamId,
        name: name,
        logoUrl: logoUrl,
        description: description,
        isRecruiting: isRecruiting,
        maxMembers: maxMembers,
        chatUrl: chatUrl,
        sportId: sportId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam(int teamId) async {
    try {
      await remoteDataSource.deleteTeam(teamId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> transferCaptain(
      {required int teamId, required int newCaptainId}) async {
    try {
      await remoteDataSource.transferCaptain(
          teamId: teamId, newCaptainId: newCaptainId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(int teamId) async {
    try {
      await remoteDataSource.leaveTeam(teamId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> kickMember(
      {required int teamId, required int userId}) async {
    try {
      await remoteDataSource.kickMember(teamId: teamId, userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

