import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/my_team_entity.dart';
import '../../domain/repositories/i_my_teams_repository.dart';
import '../datasources/my_teams_remote_datasource.dart';

/// Implementación concreta del contrato del dominio para administrar Equipos.
class MyTeamsRepositoryImpl implements IMyTeamsRepository {
  final MyTeamsRemoteDataSource remoteDataSource;

  const MyTeamsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MyTeamEntity>>> getMyTeams() async {
    try {
      final models = await remoteDataSource.getMyTeams();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> kickMember({required int teamId, required int userId}) async {
    try {
      await remoteDataSource.kickMember(teamId: teamId, userId: userId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
