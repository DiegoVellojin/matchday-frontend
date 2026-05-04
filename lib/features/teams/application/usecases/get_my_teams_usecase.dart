import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/i_teams_repository.dart';

/// Caso de Uso para consultar los equipos a los que pertenece el usuario.
class GetMyTeamsUseCase {
  final ITeamsRepository repository;

  const GetMyTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamEntity>>> call() async {
    return await repository.getMyTeams();
  }
}
