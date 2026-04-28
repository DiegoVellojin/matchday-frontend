import '../../domain/entities/team_entity.dart';

abstract class TeamsDiscoveryState {}

class TeamsDiscoveryInitial extends TeamsDiscoveryState {}

class TeamsDiscoveryLoading extends TeamsDiscoveryState {}

class TeamsDiscoveryLoaded extends TeamsDiscoveryState {
  final List<TeamEntity> teams;
  TeamsDiscoveryLoaded({required this.teams});
}

class TeamsDiscoveryError extends TeamsDiscoveryState {
  final String message;
  TeamsDiscoveryError({required this.message});
}

class TeamJoinRequestSuccess extends TeamsDiscoveryState {
  final String message;
  TeamJoinRequestSuccess({required this.message});
}
