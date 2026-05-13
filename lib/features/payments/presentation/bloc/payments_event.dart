abstract class PaymentsEvent {}

class LoadMyPaymentsEvent extends PaymentsEvent {}

class UploadReceiptEvent extends PaymentsEvent {
  final int partidaId;
  final String urlReciboPago;
  final String referenciaPago;
  final double? tasaUsadaBs;

  UploadReceiptEvent({
    required this.partidaId, 
    required this.urlReciboPago, 
    required this.referenciaPago,
    this.tasaUsadaBs,
  });
}

class VerifyPaymentEvent extends PaymentsEvent {
  final int partidaId;
  final int userId;

  VerifyPaymentEvent({required this.partidaId, required this.userId});
}
