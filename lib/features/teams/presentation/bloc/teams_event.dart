abstract class TeamsEvent {}

class LoadTeamsEvent extends TeamsEvent {}

class RequestJoinTeamEvent extends TeamsEvent {
  final int teamId;
  RequestJoinTeamEvent({required this.teamId});
}
