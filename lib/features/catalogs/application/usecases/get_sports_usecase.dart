import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams/domain/entities/sport_entity.dart';
import '../../domain/repositories/i_catalogs_repository.dart';

class GetSportsUseCase {
  final ICatalogsRepository repository;

  const GetSportsUseCase(this.repository);

  Future<Either<Failure, List<SportEntity>>> call() {
    return repository.getSports();
  }
}
