import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_discoverable_teams_usecase.dart';
import '../../application/usecases/request_join_team_usecase.dart';
import '../../application/usecases/get_sports_usecase.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/entities/sport_entity.dart';
import 'teams_discovery_event.dart';
import 'teams_discovery_state.dart';

class TeamsDiscoveryBloc
    extends Bloc<TeamsDiscoveryEvent, TeamsDiscoveryState> {
  final GetDiscoverableTeamsUseCase getTeamsUseCase;
  final RequestJoinTeamUseCase requestJoinUseCase;
  final GetSportsUseCase getSportsUseCase;

  List<TeamEntity> _currentTeams = [];
  List<SportEntity> _currentSports = [];

  TeamsDiscoveryBloc({
    required this.getTeamsUseCase,
    required this.requestJoinUseCase,
    required this.getSportsUseCase,
  }) : super(TeamsDiscoveryInitial()) {
    on<LoadTeamsEvent>((event, emit) async {
      emit(TeamsDiscoveryLoading());
      
      final teamsResult = await getTeamsUseCase();
      final sportsResult = await getSportsUseCase();

      teamsResult.fold(
        (failure) => emit(TeamsDiscoveryError(message: failure.message)),
        (teams) {
          _currentTeams = teams;
          sportsResult.fold(
            (failure) => emit(TeamsDiscoveryError(message: failure.message)),
            (sports) {
              _currentSports = sports;
              emit(TeamsDiscoveryLoaded(teams: _currentTeams, sports: _currentSports));
            },
          );
        },
      );
    });

    on<RequestJoinTeamEvent>((event, emit) async {
      final result = await requestJoinUseCase(event.teamId);
      result.fold(
        (failure) {
          emit(TeamsDiscoveryError(message: failure.message));
          emit(TeamsDiscoveryLoaded(teams: _currentTeams, sports: _currentSports));
        },
        (_) {
          emit(
            TeamJoinRequestSuccess(
              message: 'Solicitud enviada al capitán con éxito.',
            ),
          );
          emit(TeamsDiscoveryLoaded(teams: _currentTeams, sports: _currentSports));
        },
      );
    });
  }
}
