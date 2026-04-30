import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cancha_entity.dart';
import '../../domain/repositories/i_catalogs_repository.dart';

class GetCanchasUseCase {
  final ICatalogsRepository repository;

  const GetCanchasUseCase(this.repository);

  Future<Either<Failure, List<CanchaEntity>>> call({int? regionId}) {
    return repository.getCanchas(regionId: regionId);
  }
}
