import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sport_entity.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

class GetSportsUseCase {
  final ITeamsDiscoveryRepository repository;

  const GetSportsUseCase(this.repository);

  Future<Either<Failure, List<SportEntity>>> call() {
    return repository.getSports();
  }
}
