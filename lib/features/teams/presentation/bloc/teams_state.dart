import '../../domain/entities/team_entity.dart';
import '../../domain/entities/sport_entity.dart';

abstract class TeamsState {}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<TeamEntity> teams;
  final List<SportEntity> sports;
  TeamsLoaded({required this.teams, required this.sports});
}


class TeamsError extends TeamsState {
  final String message;
  TeamsError({required this.message});
}

class TeamJoinRequestSuccess extends TeamsState {
  final String message;
  TeamJoinRequestSuccess({required this.message});
}
