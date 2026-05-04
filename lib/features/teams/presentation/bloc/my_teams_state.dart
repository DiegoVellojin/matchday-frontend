import '../../domain/entities/team_entity.dart';

abstract class MyTeamsState {}

class MyTeamsInitial extends MyTeamsState {}

class MyTeamsLoading extends MyTeamsState {}

class MyTeamsLoaded extends MyTeamsState {
  final List<TeamEntity> teams;

  MyTeamsLoaded({required this.teams});
}

class MyTeamsError extends MyTeamsState {
  final String message;

  MyTeamsError({required this.message});
}

class MemberKickedSuccess extends MyTeamsState {}
