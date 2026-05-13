import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_team_leaderboard_usecase.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetTeamLeaderboardUseCase getTeamLeaderboardUseCase;

  LeaderboardBloc({required this.getTeamLeaderboardUseCase}) : super(LeaderboardInitial()) {
    on<LoadLeaderboardEvent>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboardEvent event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoading());
    final result = await getTeamLeaderboardUseCase(
      sportId: event.sportId,
      period: event.period,
    );
    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (leaderboard) => emit(LeaderboardLoaded(leaderboard)),
    );
  }
}
