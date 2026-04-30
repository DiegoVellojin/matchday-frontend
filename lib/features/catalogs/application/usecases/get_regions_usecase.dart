import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/repositories/i_catalogs_repository.dart';

class GetRegionsUseCase {
  final ICatalogsRepository repository;

  const GetRegionsUseCase(this.repository);

  Future<Either<Failure, List<RegionEntity>>> call() {
    return repository.getRegions();
  }
}
