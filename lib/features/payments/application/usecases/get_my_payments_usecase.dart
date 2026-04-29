import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/i_payments_repository.dart';

/// Caso de Uso para cargar los pagos del usuario autenticado.
class GetMyPaymentsUseCase {
  final IPaymentsRepository repository;

  const GetMyPaymentsUseCase(this.repository);

  Future<Either<Failure, List<PaymentEntity>>> call() async {
    return await repository.getMyPayments();
  }
}
