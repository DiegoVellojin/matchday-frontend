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
    int? teamId,
  }) {
    return repository.getMatches(
      sportId: sportId, 
      status: status,
      regionId: regionId,
      canchaId: canchaId,
      date: date,
      mine: mine,
      teamId: teamId,
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

  Future<Either<Failure, MatchEntity>> execute(int matchId, DateTime fecha, double costo, String moneda) {
    return repository.proposeTerms(matchId, fecha, costo, moneda);
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

  Future<Either<Failure, MatchEntity>> execute(int matchId, DateTime fecha, double costo, String moneda, String banco, String cedula, String telefono) {
    return repository.configureMatch(matchId, fecha, costo, moneda, banco, cedula, telefono);
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

class CancelMatchUseCase {
  final IMatchesRepository repository;
  CancelMatchUseCase(this.repository);

  Future<Either<Failure, void>> execute(int matchId) {
    return repository.cancelMatch(matchId);
  }
}

class UpdateMatchUseCase {
  final IMatchesRepository repository;
  UpdateMatchUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> execute(MatchEntity match) {
    return repository.updateMatch(match);
  }
}

class EvaluateMatchUseCase {
  final IMatchesRepository repository;
  EvaluateMatchUseCase(this.repository);

  Future<Either<Failure, void>> execute(int matchId, int puntuacion, String? comentario) {
    return repository.evaluateMatch(matchId, puntuacion, comentario);
  }
}
