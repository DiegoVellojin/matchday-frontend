import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasources/matches_remote_datasource.dart';
import '../models/match_model.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  MatchesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MatchEntity>>> getMatches({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
    bool? mine,
  }) async {
    try {
      final results = await remoteDataSource.getMatches(
        sportId: sportId, 
        status: status,
        regionId: regionId,
        canchaId: canchaId,
        date: date,
        mine: mine,
      );
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> createMatch(MatchEntity match) async {
    try {
      final model = MatchModel(
        id: match.id,
        fechaInicioEstimada: match.fechaInicioEstimada,
        fechaFinEstimada: match.fechaFinEstimada,
        fechaAcordada: match.fechaAcordada,
        costoTotal: match.costoTotal,
        estatus: match.estatus,
        idUsuarioOrg: match.idUsuarioOrg,
        idDeporte: match.idDeporte,
        idCancha: match.idCancha,
        idEquipoA: match.idEquipoA,
        idEquipoB: match.idEquipoB,
      );
      final result = await remoteDataSource.createMatch(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> getMatchDetails(int id) async {
    try {
      final result = await remoteDataSource.getMatchDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> acceptEncounter(int matchId, int teamId) async {
    try {
      final result = await remoteDataSource.acceptEncounter(matchId, teamId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> proposeTerms(int matchId, DateTime fecha, double costo) async {
    try {
      final result = await remoteDataSource.proposeTerms(matchId, fecha, costo);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> configureMatch(int matchId, DateTime fecha, double costo, String banco, String cedula, String telefono) async {
    try {
      final result = await remoteDataSource.configureMatch(matchId, fecha, costo, banco, cedula, telefono);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> markTeamReady(int matchId) async {
    try {
      final result = await remoteDataSource.markTeamReady(matchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerResult(int matchId, int golesA, int golesB) async {
    try {
      await remoteDataSource.registerResult(matchId, golesA, golesB);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinMatch(int matchId, {int? teamId}) async {
    try {
      await remoteDataSource.joinMatch(matchId, teamId: teamId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchPlayer>>> getMatchPlayers(int matchId) async {
    try {
      final result = await remoteDataSource.getMatchPlayers(matchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
