import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/my_team_entity.dart';
import '../../domain/repositories/i_my_teams_repository.dart';

/// Caso de Uso para consultar los equipos a los que pertenece el usuario.
class GetMyTeamsUseCase {
  final IMyTeamsRepository repository;

  const GetMyTeamsUseCase(this.repository);

  Future<Either<Failure, List<MyTeamEntity>>> call() async {
    return await repository.getMyTeams();
  }
}
