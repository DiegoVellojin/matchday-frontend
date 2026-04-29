/// Entidad de dominio pura que representa a un Equipo en el contexto del usuario actual.
class MyTeamEntity {
  final int id;
  final String name;
  final String logo;
  final String sportName;
  final int maxMembers;
  final int currentMembers;
  final bool isRecruiting;
  final int? captainId;
  final String? urlChatEquipo;

  const MyTeamEntity({
    required this.id,
    required this.name,
    required this.logo,
    required this.sportName,
    required this.maxMembers,
    required this.currentMembers,
    required this.isRecruiting,
    this.captainId,
    this.urlChatEquipo,
  });

}
