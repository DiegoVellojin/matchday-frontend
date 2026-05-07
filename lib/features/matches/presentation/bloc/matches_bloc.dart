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
  final int? regionId;
  final int? canchaId;
  final DateTime? date;
  final bool? mine;
  final int? teamId;
  
  LoadMatchesEvent({
    this.sportId, 
    this.status,
    this.regionId,
    this.canchaId,
    this.date,
    this.mine,
    this.teamId,
  });

  @override
  List<Object?> get props => [sportId, status, regionId, canchaId, date, mine, teamId];
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

class AcceptEncounterEvent extends MatchesEvent {
  final int matchId;
  final int teamId;
  AcceptEncounterEvent({required this.matchId, required this.teamId});
  @override
  List<Object?> get props => [matchId, teamId];
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

class ConfigureMatchEvent extends MatchesEvent {
  final int matchId;
  final DateTime fecha;
  final double costo;
  final String banco;
  final String cedula;
  final String telefono;
  
  ConfigureMatchEvent({
    required this.matchId,
    required this.fecha,
    required this.costo,
    required this.banco,
    required this.cedula,
    required this.telefono,
  });
}

class MarkTeamReadyEvent extends MatchesEvent {
  final int matchId;
  MarkTeamReadyEvent(this.matchId);
}

class RegisterResultEvent extends MatchesEvent {
  final int matchId;
  final int golesA;
  final int golesB;
  RegisterResultEvent({required this.matchId, required this.golesA, required this.golesB});
}

class CancelMatchEvent extends MatchesEvent {
  final int matchId;
  CancelMatchEvent(this.matchId);
}

class UpdateMatchEvent extends MatchesEvent {
  final MatchEntity match;
  UpdateMatchEvent(this.match);
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
class MatchConfigured extends MatchesState {
  final MatchEntity match;
  MatchConfigured(this.match);
  @override
  List<Object?> get props => [match];
}
class TeamMarkedReady extends MatchesState {
  final MatchEntity match;
  TeamMarkedReady(this.match);
  @override
  List<Object?> get props => [match];
}
class MatchResultRegistered extends MatchesState {}
class MatchEncounterAccepted extends MatchesState {
  final MatchEntity match;
  MatchEncounterAccepted(this.match);
  @override
  List<Object?> get props => [match];
}
class MatchCancelled extends MatchesState {}
class MatchUpdated extends MatchesState {
  final MatchEntity match;
  MatchUpdated(this.match);
  @override
  List<Object?> get props => [match];
}

// BLOC
class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final GetMatchesUseCase getMatchesUseCase;
  final GetMatchDetailsUseCase getMatchDetailsUseCase;
  final CreateMatchUseCase createMatchUseCase;
  final ProposeTermsUseCase proposeTermsUseCase;
  final ConfigureMatchUseCase configureMatchUseCase;
  final MarkTeamReadyUseCase markTeamReadyUseCase;
  final RegisterMatchResultUseCase registerMatchResultUseCase;
  final AcceptEncounterUseCase acceptEncounterUseCase;
  final CancelMatchUseCase cancelMatchUseCase;
  final UpdateMatchUseCase updateMatchUseCase;

  MatchesBloc({
    required this.getMatchesUseCase,
    required this.getMatchDetailsUseCase,
    required this.createMatchUseCase,
    required this.proposeTermsUseCase,
    required this.configureMatchUseCase,
    required this.markTeamReadyUseCase,
    required this.registerMatchResultUseCase,
    required this.acceptEncounterUseCase,
    required this.cancelMatchUseCase,
    required this.updateMatchUseCase,
  }) : super(MatchesInitial()) {
    on<LoadMatchesEvent>(_onLoadMatches);
    on<LoadMatchDetailsEvent>(_onLoadMatchDetails);
    on<SearchSimilarMatchesEvent>(_onSearchSimilar);
    on<AcceptEncounterEvent>(_onAcceptEncounter);
    on<CreateMatchEvent>(_onCreateMatch);
    on<ProposeTermsEvent>(_onProposeTerms);
    on<ConfigureMatchEvent>(_onConfigureMatch);
    on<MarkTeamReadyEvent>(_onMarkTeamReady);
    on<RegisterResultEvent>(_onRegisterResult);
    on<CancelMatchEvent>(_onCancelMatch);
    on<UpdateMatchEvent>(_onUpdateMatch);
  }

  Future<void> _onAcceptEncounter(AcceptEncounterEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await acceptEncounterUseCase.execute(event.matchId, event.teamId);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(MatchEncounterAccepted(match)),
    );
  }

  Future<void> _onLoadMatches(LoadMatchesEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await getMatchesUseCase.execute(
      sportId: event.sportId, 
      status: event.status,
      regionId: event.regionId,
      canchaId: event.canchaId,
      date: event.date,
      mine: event.mine,
      teamId: event.teamId,
    );
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

  Future<void> _onConfigureMatch(ConfigureMatchEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await configureMatchUseCase.execute(
      event.matchId, event.fecha, event.costo, event.banco, event.cedula, event.telefono
    );
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(MatchConfigured(match)),
    );
  }

  Future<void> _onMarkTeamReady(MarkTeamReadyEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await markTeamReadyUseCase.execute(event.matchId);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(TeamMarkedReady(match)),
    );
  }

  Future<void> _onRegisterResult(RegisterResultEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await registerMatchResultUseCase.execute(event.matchId, event.golesA, event.golesB);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (_) => emit(MatchResultRegistered()),
    );
  }

  Future<void> _onCancelMatch(CancelMatchEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await cancelMatchUseCase.execute(event.matchId);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (_) => emit(MatchCancelled()),
    );
  }

  Future<void> _onUpdateMatch(UpdateMatchEvent event, Emitter<MatchesState> emit) async {
    emit(MatchesLoading());
    final result = await updateMatchUseCase.execute(event.match);
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (match) => emit(MatchUpdated(match)),
    );
  }
}
