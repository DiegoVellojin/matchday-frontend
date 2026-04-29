import '../../domain/entities/payment_entity.dart';

/// Modelo de datos para pagos.
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.idPartida,
    required super.teamName,
    super.teamLogo,
    required super.concepto,
    required super.monto,
    required super.isPaid,
    required super.estatusPago,
    super.urlReciboPago,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      idPartida: json['id_partida'] ?? 0,
      teamName: json['team_name'] ?? 'Sin Equipo',
      teamLogo: json['team_logo'],
      concepto: json['concepto'] ?? 'Reserva de Cancha',
      monto: (json['monto'] ?? 0).toDouble(),
      isPaid: json['is_paid'] ?? false,
      estatusPago: json['estatus_pago'] ?? 'pendiente',
      urlReciboPago: json['url_recibo_pago'],
    );
  }
}
