import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_my_teams_usecase.dart';
import '../../application/usecases/kick_member_usecase.dart';
import 'my_teams_event.dart';
import 'my_teams_state.dart';

/// Controlador de estados (BLoC) que orquesta la lógica del negocio de Mis Equipos.
class MyTeamsBloc extends Bloc<MyTeamsEvent, MyTeamsState> {
  final GetMyTeamsUseCase getMyTeamsUseCase;
  final KickMemberUseCase kickMemberUseCase;

  MyTeamsBloc({
    required this.getMyTeamsUseCase,
    required this.kickMemberUseCase,
  }) : super(MyTeamsInitial()) {
    
    on<LoadMyTeamsEvent>((event, emit) async {
      emit(MyTeamsLoading());
      final result = await getMyTeamsUseCase();
      
      result.fold(
        (failure) => emit(MyTeamsError(message: failure.message)),
        (teams) => emit(MyTeamsLoaded(teams: teams)),
      );
    });

    on<KickTeamMemberEvent>((event, emit) async {
      final result = await kickMemberUseCase(
        teamId: event.teamId,
        userId: event.userId,
      );

      result.fold(
        (failure) => emit(MyTeamsError(message: failure.message)),
        (_) {
          emit(MemberKickedSuccess());
          add(LoadMyTeamsEvent()); // Recargar lista automáticamente
        },
      );
    });
  }
}
