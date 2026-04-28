import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_discoverable_teams_usecase.dart';
import '../../application/usecases/request_join_team_usecase.dart';
import '../../domain/entities/team_entity.dart';
import 'teams_discovery_event.dart';
import 'teams_discovery_state.dart';

class TeamsDiscoveryBloc
    extends Bloc<TeamsDiscoveryEvent, TeamsDiscoveryState> {
  final GetDiscoverableTeamsUseCase getTeamsUseCase;
  final RequestJoinTeamUseCase requestJoinUseCase;

  // Mantenemos una caché en memoria de los equipos para no recargar todo si la solicitud es exitosa
  List<TeamEntity> _currentTeams = [];

  TeamsDiscoveryBloc({
    required this.getTeamsUseCase,
    required this.requestJoinUseCase,
  }) : super(TeamsDiscoveryInitial()) {
    on<LoadTeamsEvent>((event, emit) async {
      emit(TeamsDiscoveryLoading());
      final result = await getTeamsUseCase();
      result.fold(
        (failure) => emit(TeamsDiscoveryError(message: failure.message)),
        (teams) {
          _currentTeams = teams;
          emit(TeamsDiscoveryLoaded(teams: _currentTeams));
        },
      );
    });

    on<RequestJoinTeamEvent>((event, emit) async {
      // No emitimos Loading genérico para no borrar la lista de la pantalla
      final result = await requestJoinUseCase(event.teamId);
      result.fold(
        (failure) {
          emit(TeamsDiscoveryError(message: failure.message));
          // Inmediatamente regresamos al estado Loaded para que la grilla se siga viendo
          emit(TeamsDiscoveryLoaded(teams: _currentTeams));
        },
        (_) {
          emit(
            TeamJoinRequestSuccess(
              message: 'Solicitud enviada al capitán con éxito.',
            ),
          );
          // Inmediatamente regresamos al estado Loaded para que la grilla se siga viendo
          emit(TeamsDiscoveryLoaded(teams: _currentTeams));
        },
      );

    });
  }
}
