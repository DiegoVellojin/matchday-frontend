import '../../../../core/network/network_robot.dart';
import '../models/payment_model.dart';

/// Cliente API para comunicarse con los endpoints de pagos.
class PaymentsRemoteDataSource {
  final NetworkRobot networkRobot;

  const PaymentsRemoteDataSource(this.networkRobot);

  /// Obtiene los pagos del usuario.
  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await networkRobot.get('/payments/my');
      final List<dynamic> data = response.data;
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener los pagos desde el servidor.');
    }
  }

  /// Envía el comprobante de pago.
  Future<void> uploadReceipt({required int partidaId, required String urlReciboPago}) async {
    try {
      await networkRobot.put(
        '/payments/$partidaId/upload-receipt',
        data: {'url_recibo_pago': urlReciboPago},
      );
    } catch (e) {
      throw Exception('Error al reportar el comprobante de pago.');
    }
  }
}
