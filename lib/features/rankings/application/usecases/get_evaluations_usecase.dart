import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_rankings_repository.dart';

class GetEvaluationsUseCase {
  final IRankingsRepository repository;

  GetEvaluationsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call({
    required int targetId,
    required bool isTeam,
  }) {
    return repository.getEvaluations(targetId: targetId, isTeam: isTeam);
  }
}
