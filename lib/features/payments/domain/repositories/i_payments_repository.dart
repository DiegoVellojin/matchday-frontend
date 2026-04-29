import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';

/// Contrato para interactuar con la gestión de pagos.
abstract class IPaymentsRepository {
  /// Obtiene los pagos del usuario.
  Future<Either<Failure, List<PaymentEntity>>> getMyPayments();

  /// Sube la URL del comprobante de pago.
  Future<Either<Failure, Unit>> uploadReceipt({required int partidaId, required String urlReciboPago});
}
