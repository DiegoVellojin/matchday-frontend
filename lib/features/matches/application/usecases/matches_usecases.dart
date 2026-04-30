import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';

class GetMatchesUseCase {
  final IMatchesRepository repository;
  GetMatchesUseCase(this.repository);

  Future<Either<Failure, List<MatchEntity>>> execute({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
  }) {
    return repository.getMatches(
      sportId: sportId, 
      status: status,
      regionId: regionId,
      canchaId: canchaId,
      date: date,
    );
  }
}

class GetMatchDetailsUseCase {
  final IMatchesRepository repository;
  GetMatchDetailsUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(int id) {
    return repository.getMatchDetails(id);
  }
}

class CreateMatchUseCase {
  final IMatchesRepository repository;
  CreateMatchUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(MatchEntity match) {
    return repository.createMatch(match);
  }
}

class AcceptEncounterUseCase {
  final IMatchesRepository repository;
  AcceptEncounterUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(int matchId, int teamId) {
    return repository.acceptEncounter(matchId, teamId);
  }
}

class ProposeTermsUseCase {
  final IMatchesRepository repository;
  ProposeTermsUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(int matchId, DateTime fecha, double costo) {
    return repository.proposeTerms(matchId, fecha, costo);
  }
}

class JoinMatchUseCase {
  final IMatchesRepository repository;
  JoinMatchUseCase(this.repository);

  Future<Either<Failure, void>> execute(int matchId, {int? teamId}) {
    return repository.joinMatch(matchId, teamId: teamId);
  }
}
