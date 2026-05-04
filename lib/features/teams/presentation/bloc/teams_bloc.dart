import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_discoverable_teams_usecase.dart';
import '../../application/usecases/request_join_team_usecase.dart';
import '../../application/usecases/get_sports_usecase.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/sport_entity.dart';
import 'teams_event.dart';
import 'teams_state.dart';

class TeamsBloc
    extends Bloc<TeamsEvent, TeamsState> {
  final GetDiscoverableTeamsUseCase getTeamsUseCase;
  final RequestJoinTeamUseCase requestJoinUseCase;
  final GetSportsUseCase getSportsUseCase;

  List<TeamEntity> _currentTeams = [];
  List<SportEntity> _currentSports = [];

  TeamsBloc({
    required this.getTeamsUseCase,
    required this.requestJoinUseCase,
    required this.getSportsUseCase,
  }) : super(TeamsInitial()) {
    on<LoadTeamsEvent>((event, emit) async {
      emit(TeamsLoading());
      
      final teamsResult = await getTeamsUseCase();
      final sportsResult = await getSportsUseCase();

      teamsResult.fold(
        (failure) => emit(TeamsError(message: failure.message)),
        (teams) {
          _currentTeams = teams;
          sportsResult.fold(
            (failure) => emit(TeamsError(message: failure.message)),
            (sports) {
              _currentSports = sports;
              emit(TeamsLoaded(teams: _currentTeams, sports: _currentSports));
            },
          );
        },
      );
    });

    on<RequestJoinTeamEvent>((event, emit) async {
      final result = await requestJoinUseCase(event.teamId);
      result.fold(
        (failure) {
          emit(TeamsError(message: failure.message));
          emit(TeamsLoaded(teams: _currentTeams, sports: _currentSports));
        },
        (_) {
          emit(
            TeamJoinRequestSuccess(
              message: 'Solicitud enviada al capitán con éxito.',
            ),
          );
          emit(TeamsLoaded(teams: _currentTeams, sports: _currentSports));
        },
      );
    });
  }
}
