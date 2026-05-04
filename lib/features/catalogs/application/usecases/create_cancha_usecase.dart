import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cancha_entity.dart';
import '../../domain/repositories/i_catalogs_repository.dart';

class CreateCanchaUseCase {
  final ICatalogsRepository repository;

  CreateCanchaUseCase(this.repository);

  Future<Either<Failure, CanchaEntity>> call(CanchaEntity cancha) async {
    return await repository.createCancha(cancha);
  }
}
