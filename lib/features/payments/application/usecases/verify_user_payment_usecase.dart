import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_payments_repository.dart';

class VerifyUserPaymentUseCase {
  final IPaymentsRepository repository;

  const VerifyUserPaymentUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required int partidaId, required int userId}) {
    return repository.verifyUserPayment(partidaId: partidaId, userId: userId);
  }
}
