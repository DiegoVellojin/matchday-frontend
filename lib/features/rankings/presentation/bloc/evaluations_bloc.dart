import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review_entity.dart';
import '../../application/usecases/get_evaluations_usecase.dart';

// Events
abstract class EvaluationsEvent extends Equatable {
  const EvaluationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvaluationsEvent extends EvaluationsEvent {
  final int targetId;
  final bool isTeam;

  const LoadEvaluationsEvent({required this.targetId, required this.isTeam});

  @override
  List<Object?> get props => [targetId, isTeam];
}

// States
abstract class EvaluationsState extends Equatable {
  const EvaluationsState();
  @override
  List<Object?> get props => [];
}

class EvaluationsInitial extends EvaluationsState {}
class EvaluationsLoading extends EvaluationsState {}
class EvaluationsLoaded extends EvaluationsState {
  final List<ReviewEntity> evaluations;
  const EvaluationsLoaded(this.evaluations);
  @override
  List<Object?> get props => [evaluations];
}
class EvaluationsError extends EvaluationsState {
  final String message;
  const EvaluationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class EvaluationsBloc extends Bloc<EvaluationsEvent, EvaluationsState> {
  final GetEvaluationsUseCase getEvaluationsUseCase;

  EvaluationsBloc({required this.getEvaluationsUseCase}) : super(EvaluationsInitial()) {
    on<LoadEvaluationsEvent>((event, emit) async {
      emit(EvaluationsLoading());
      final result = await getEvaluationsUseCase.call(
        targetId: event.targetId,
        isTeam: event.isTeam,
      );
      result.fold(
        (failure) => emit(EvaluationsError(failure.message)),
        (evaluations) => emit(EvaluationsLoaded(evaluations)),
      );
    });
  }
}
