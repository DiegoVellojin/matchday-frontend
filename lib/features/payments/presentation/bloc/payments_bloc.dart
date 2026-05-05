import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_my_payments_usecase.dart';
import '../../application/usecases/upload_receipt_usecase.dart';
import '../../application/usecases/verify_user_payment_usecase.dart';
import 'payments_event.dart';
import 'payments_state.dart';

/// Controlador de estados (BLoC) que orquesta la lógica del negocio de Pagos.
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetMyPaymentsUseCase getMyPaymentsUseCase;
  final UploadReceiptUseCase uploadReceiptUseCase;
  final VerifyUserPaymentUseCase verifyUserPaymentUseCase;

  PaymentsBloc({
    required this.getMyPaymentsUseCase,
    required this.uploadReceiptUseCase,
    required this.verifyUserPaymentUseCase,
  }) : super(PaymentsInitial()) {
    
    on<LoadMyPaymentsEvent>((event, emit) async {
      emit(PaymentsLoading());
      final result = await getMyPaymentsUseCase();
      
      result.fold(
        (failure) => emit(PaymentsError(message: failure.message)),
        (payments) => emit(PaymentsLoaded(payments: payments)),
      );
    });

    on<UploadReceiptEvent>((event, emit) async {
      emit(PaymentsLoading());
      final result = await uploadReceiptUseCase(
        partidaId: event.partidaId,
        urlReciboPago: event.urlReciboPago,
        referenciaPago: event.referenciaPago,
      );

      result.fold(
        (failure) => emit(PaymentsError(message: failure.message)),
        (_) {
          emit(ReceiptUploadedSuccess());
          add(LoadMyPaymentsEvent()); // Recargar lista automáticamente
        },
      );
    });

    on<VerifyPaymentEvent>((event, emit) async {
      emit(PaymentsLoading());
      final result = await verifyUserPaymentUseCase(
        partidaId: event.partidaId,
        userId: event.userId,
      );

      result.fold(
        (failure) => emit(PaymentsError(message: failure.message)),
        (_) {
          emit(PaymentVerifiedSuccess());
          // Optional: Add logic to reload team payments if we had a LoadTeamPaymentsEvent
        },
      );
    });
  }
}
