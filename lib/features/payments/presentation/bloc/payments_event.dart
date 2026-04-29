abstract class PaymentsEvent {}

class LoadMyPaymentsEvent extends PaymentsEvent {}

class UploadReceiptEvent extends PaymentsEvent {
  final int partidaId;
  final String urlReciboPago;

  UploadReceiptEvent({required this.partidaId, required this.urlReciboPago});
}
