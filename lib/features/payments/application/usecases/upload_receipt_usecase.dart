import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_payments_repository.dart';

/// Caso de Uso para reportar el recibo de pago de una partida.
class UploadReceiptUseCase {
  final IPaymentsRepository repository;

  const UploadReceiptUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required int partidaId, 
    required String urlReciboPago, 
    required String referenciaPago,
    double? tasaUsadaBs,
  }) async {
    return await repository.uploadReceipt(
      partidaId: partidaId, 
      urlReciboPago: urlReciboPago, 
      referenciaPago: referenciaPago,
      tasaUsadaBs: tasaUsadaBs,
    );
  }
}
