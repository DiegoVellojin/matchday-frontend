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
    int? teamId,
  }) async {
    try {
      final results = await remoteDataSource.getMatches(
        sportId: sportId, 
        status: status,
        regionId: regionId,
        canchaId: canchaId,
        date: date,
        mine: mine,
        teamId: teamId,
      );
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
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
        status: match.status,
        idUsuarioOrg: match.idUsuarioOrg,
        idDeporte: match.idDeporte,
        idCancha: match.idCancha,
        idEquipoA: match.idEquipoA,
        idEquipoB: match.idEquipoB,
        moneda: match.moneda,
        cuposTotales: match.cuposTotales,
        jugadoresInscritos: match.jugadoresInscritos,
        cuotaPorJugador: match.cuotaPorJugador,
        propuestaFechaA: match.propuestaFechaA,
        propuestaCostoA: match.propuestaCostoA,
        propuestaMonedaA: match.propuestaMonedaA,
        propuestaFechaB: match.propuestaFechaB,
        propuestaCostoB: match.propuestaCostoB,
        propuestaMonedaB: match.propuestaMonedaB,
      );
      final result = await remoteDataSource.createMatch(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> getMatchDetails(int id) async {
    try {
      final result = await remoteDataSource.getMatchDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> acceptEncounter(int matchId, int teamId) async {
    try {
      final result = await remoteDataSource.acceptEncounter(matchId, teamId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> proposeTerms(int matchId, DateTime fecha, double costo, String moneda) async {
    try {
      final result = await remoteDataSource.proposeTerms(matchId, fecha, costo, moneda);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> configureMatch(int matchId, DateTime fecha, double costo, String moneda, String banco, String cedula, String telefono) async {
    try {
      final result = await remoteDataSource.configureMatch(matchId, fecha, costo, moneda, banco, cedula, telefono);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> markTeamReady(int matchId) async {
    try {
      final result = await remoteDataSource.markTeamReady(matchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> registerResult(int matchId, int golesA, int golesB) async {
    try {
      await remoteDataSource.registerResult(matchId, golesA, golesB);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> joinMatch(int matchId, {int? teamId}) async {
    try {
      await remoteDataSource.joinMatch(matchId, teamId: teamId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<MatchPlayer>>> getMatchPlayers(int matchId) async {
    try {
      final result = await remoteDataSource.getMatchPlayers(matchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMatch(int matchId) async {
    try {
      await remoteDataSource.cancelMatch(matchId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> updateMatch(MatchEntity match) async {
    try {
      final model = MatchModel(
        id: match.id,
        fechaInicioEstimada: match.fechaInicioEstimada,
        fechaFinEstimada: match.fechaFinEstimada,
        fechaAcordada: match.fechaAcordada,
        costoTotal: match.costoTotal,
        status: match.status,
        idUsuarioOrg: match.idUsuarioOrg,
        idDeporte: match.idDeporte,
        idCancha: match.idCancha,
        idEquipoA: match.idEquipoA,
        idEquipoB: match.idEquipoB,
        moneda: match.moneda,
        cuposTotales: match.cuposTotales,
        jugadoresInscritos: match.jugadoresInscritos,
        cuotaPorJugador: match.cuotaPorJugador,
        propuestaFechaA: match.propuestaFechaA,
        propuestaCostoA: match.propuestaCostoA,
        propuestaMonedaA: match.propuestaMonedaA,
        propuestaFechaB: match.propuestaFechaB,
        propuestaCostoB: match.propuestaCostoB,
        propuestaMonedaB: match.propuestaMonedaB,
      );
      final result = await remoteDataSource.updateMatch(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
