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
  });
  Future<Either<Failure, MatchEntity>> createMatch(MatchEntity match);
  Future<Either<Failure, MatchEntity>> getMatchDetails(int id);
  Future<Either<Failure, MatchEntity>> acceptEncounter(int matchId, int teamId);
  Future<Either<Failure, MatchEntity>> proposeTerms(int matchId, DateTime fecha, double costo);
  Future<Either<Failure, void>> joinMatch(int matchId, {int? teamId});
}
