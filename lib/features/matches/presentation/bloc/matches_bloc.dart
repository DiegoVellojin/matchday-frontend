import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/match_entity.dart';
import '../../application/usecases/matches_usecases.dart';

// EVENTS
abstract class MatchesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMatchesEvent extends MatchesEvent {
  final int? sportId;
  final String? status;
  LoadMatchesEvent({this.sportId, this.status});
}

class LoadMatchDetailsEvent extends MatchesEvent {
  final int matchId;
  LoadMatchDetailsEvent(this.matchId);
}

class SearchSimilarMatchesEvent extends MatchesEvent {
  final int sportId;
  final DateTime date;
  SearchSimilarMatchesEvent({required this.sportId, required this.date});
}

class CreateMatchEvent extends MatchesEvent {
  final MatchEntity match;
  CreateMatchEvent(this.match);
}

class ProposeTermsEvent extends MatchesEvent {
  final int matchId;
  final DateTime fecha;
  final double costo;
  ProposeTermsEvent({required this.matchId, required this.fecha, required this.costo});
}

// STATES
abstract class MatchesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {}
class MatchesLoading extends MatchesState {}
class MatchesLoaded extends MatchesState {
  final List<MatchEntity> matches;
  MatchesLoaded(this.matches);
  @override
  List<Object?> get props => [matches];
}
class MatchDetailsLoaded extends MatchesState {
  final MatchEntity match;
  MatchDetailsLoaded(this.match);
  @override
  List<Object?> get props => [match];
}
class SimilarMatchesFound extends MatchesState {
  final List<MatchEntity> similarMatches;
  SimilarMatchesFound(this.similarMatches);
  @override
  List<Object?> get props => [similarMatches];
}
class MatchCreated extends MatchesState {}
class MatchesError extends MatchesState {
  final String message;
  MatchesError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final GetMatchesUseCase getMatchesUseCase;
  final GetMatchDetailsUseCase getMatchDetailsUseCase;
  final CreateMatchUseCase createMatchUseCase;
  final ProposeTermsUseCase proposeTermsUseCase;

  MatchesBloc({
    required this.getMatchesUseCase,
    required this.getMatchDetailsUseCase,
    required this.createMatchUseCase,
    required this.proposeTermsUseCase,
  }) : super(MatchesInitial()) {
    on<LoadMatchesEvent>(_onLoadMatches);
    on<LoadMatchDetailsEvent>(_onLoadMatchDetails);
    on<SearchSimilarMatchesEvent>(_onSearchSimilar);
    on<CreateMatchEvent>(_onCreateMatch);
    on<ProposeTermsEvent>(_onProposeTerms);
  }

  Future<void> _onLoadMatches(LoadMatchesEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await getMatchesUseCase.execute(sportId: event.sportId, status: event.status);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (matches) => emit(MatchesLoaded(matches)),
    );
  }

  Future<void> _onLoadMatchDetails(LoadMatchDetailsEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await getMatchDetailsUseCase.execute(event.matchId);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(MatchDetailsLoaded(match)),
    );
  }

  Future<void> _onSearchSimilar(SearchSimilarMatchesEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    // Por ahora usamos GetMatches con filtros. En el futuro puede ser un endpoint específico.
    final result = await getMatchesUseCase.execute(sportId: event.sportId);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (matches) {
        // Filtrar por fecha cercana (mismo día por ahora)
        final similar = matches.where((m) => 
          m.fechaInicioEstimada.year == event.date.year &&
          m.fechaInicioEstimada.month == event.date.month &&
          m.fechaInicioEstimada.day == event.date.day
        ).toList();
        
        emit(SimilarMatchesFound(similar));
      },
    );
  }

  Future<void> _onCreateMatch(CreateMatchEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await createMatchUseCase.execute(event.match);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (_) => emit(MatchCreated()),
    );
  }

  Future<void> _onProposeTerms(ProposeTermsEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await proposeTermsUseCase.execute(event.matchId, event.fecha, event.costo);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(MatchDetailsLoaded(match)),
    );
  }
}
