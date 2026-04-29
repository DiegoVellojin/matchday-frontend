import '../../domain/entities/payment_entity.dart';

abstract class PaymentsState {}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentEntity> payments;

  PaymentsLoaded({required this.payments});
}

class PaymentsError extends PaymentsState {
  final String message;

  PaymentsError({required this.message});
}

class ReceiptUploadedSuccess extends PaymentsState {}
