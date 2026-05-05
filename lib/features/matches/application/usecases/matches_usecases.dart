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
    bool? mine,
  }) {
    return repository.getMatches(
      sportId: sportId, 
      status: status,
      regionId: regionId,
      canchaId: canchaId,
      date: date,
      mine: mine,
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

class ConfigureMatchUseCase {
  final IMatchesRepository repository;
  ConfigureMatchUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(int matchId, DateTime fecha, double costo, String banco, String cedula, String telefono) {
    return repository.configureMatch(matchId, fecha, costo, banco, cedula, telefono);
  }
}

class MarkTeamReadyUseCase {
  final IMatchesRepository repository;
  MarkTeamReadyUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(int matchId) {
    return repository.markTeamReady(matchId);
  }
}

class RegisterMatchResultUseCase {
  final IMatchesRepository repository;
  RegisterMatchResultUseCase(this.repository);

  Future<Either<Failure, void>> execute(int matchId, int golesA, int golesB) {
    return repository.registerResult(matchId, golesA, golesB);
  }
}
