import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/i_payments_repository.dart';
import '../datasources/payments_remote_data_source.dart';

/// Implementación del repositorio de pagos.
class PaymentsRepositoryImpl implements IPaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  const PaymentsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PaymentEntity>>> getMyPayments() async {
    try {
      final models = await remoteDataSource.getMyPayments();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadReceipt({required int partidaId, required String urlReciboPago}) async {
    try {
      await remoteDataSource.uploadReceipt(partidaId: partidaId, urlReciboPago: urlReciboPago);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
