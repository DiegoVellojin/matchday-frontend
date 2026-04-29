/// Entidad de dominio pura que representa el estado de un pago.
class PaymentEntity {
  final int idPartida;
  final String teamName;
  final String? teamLogo;
  final String concepto;
  final double monto;
  final bool isPaid;
  final String estatusPago;
  final String? urlReciboPago;

  const PaymentEntity({
    required this.idPartida,
    required this.teamName,
    this.teamLogo,
    required this.concepto,
    required this.monto,
    required this.isPaid,
    required this.estatusPago,
    this.urlReciboPago,
  });
}
