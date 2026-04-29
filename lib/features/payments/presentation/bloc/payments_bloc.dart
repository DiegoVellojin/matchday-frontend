import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_my_payments_usecase.dart';
import '../../application/usecases/upload_receipt_usecase.dart';
import 'payments_event.dart';
import 'payments_state.dart';

/// Controlador de estados (BLoC) que orquesta la lógica del negocio de Pagos.
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetMyPaymentsUseCase getMyPaymentsUseCase;
  final UploadReceiptUseCase uploadReceiptUseCase;

  PaymentsBloc({
    required this.getMyPaymentsUseCase,
    required this.uploadReceiptUseCase,
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
      final result = await uploadReceiptUseCase(
        partidaId: event.partidaId,
        urlReciboPago: event.urlReciboPago,
      );

      result.fold(
        (failure) => emit(PaymentsError(message: failure.message)),
        (_) {
          emit(ReceiptUploadedSuccess());
          add(LoadMyPaymentsEvent()); // Recargar lista automáticamente
        },
      );
    });
  }
}
