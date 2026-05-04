abstract class MyTeamsEvent {}

/// Evento para cargar los equipos del usuario actual.
class LoadMyTeamsEvent extends MyTeamsEvent {}

/// Evento para expulsar a un miembro de un equipo específico.
class KickTeamMemberEvent extends MyTeamsEvent {
  final int teamId;
  final int userId;

  KickTeamMemberEvent({required this.teamId, required this.userId});
}
