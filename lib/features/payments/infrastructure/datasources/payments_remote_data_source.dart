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
  Future<void> uploadReceipt({
    required int partidaId, 
    required String urlReciboPago, 
    required String referenciaPago,
    double? tasaUsadaBs,
  }) async {
    try {
      await networkRobot.post(
        '/payments/$partidaId/upload',
        data: {
          'url_recibo_pago': urlReciboPago,
          'referencia_pago': referenciaPago,
          'tasa_usada_bs': tasaUsadaBs,
        },
      );
    } catch (e) {
      throw Exception('Error al reportar el comprobante de pago.');
    }
  }

  /// Verifica el pago de un jugador (Capitán).
  Future<void> verifyUserPayment({required int partidaId, required int userId}) async {
    try {
      await networkRobot.put(
        '/payments/verify',
        data: {
          'id_partida': partidaId,
          'id_usuario': userId,
        },
      );
    } catch (e) {
      throw Exception('Error al verificar el pago del jugador.');
    }
  }
}
