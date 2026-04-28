abstract class TeamsDiscoveryEvent {}

class LoadTeamsEvent extends TeamsDiscoveryEvent {}

class RequestJoinTeamEvent extends TeamsDiscoveryEvent {
  final int teamId;
  RequestJoinTeamEvent({required this.teamId});
}
