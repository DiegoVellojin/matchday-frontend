import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/match_entity.dart';

abstract class IMatchesRepository {
  Future<Either<Failure, List<MatchEntity>>> getMatches({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
    bool? mine,
    int? teamId,
  });
  Future<Either<Failure, MatchEntity>> createMatch(MatchEntity match);
  Future<Either<Failure, MatchEntity>> getMatchDetails(int id);
  Future<Either<Failure, MatchEntity>> acceptEncounter(int matchId, int teamId);
  Future<Either<Failure, MatchEntity>> proposeTerms(int matchId, DateTime fecha, double costo, String moneda);
  Future<Either<Failure, MatchEntity>> configureMatch(int matchId, DateTime fecha, double costo, String moneda, String banco, String cedula, String telefono);
  Future<Either<Failure, MatchEntity>> markTeamReady(int matchId);
  Future<Either<Failure, void>> registerResult(int matchId, int golesA, int golesB);
  Future<Either<Failure, void>> joinMatch(int matchId, {int? teamId});
  Future<Either<Failure, List<MatchPlayer>>> getMatchPlayers(int matchId);
  Future<Either<Failure, void>> cancelMatch(int matchId);
  Future<Either<Failure, MatchEntity>> updateMatch(MatchEntity match);
}
