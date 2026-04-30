class TeamEntity {
  final int id;
  final String name;
  final String logo;
  final String sportName;
  final int maxMembers;
  final int currentMembers;
  final bool isRecruiting;
  final bool soyMiembro;
  final int? captainId;
  final String description;
  final String? chatUrl;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.logo,
    required this.sportName,
    required this.maxMembers,
    required this.currentMembers,
    required this.isRecruiting,
    required this.soyMiembro,
    this.captainId,
    this.description = '',
    this.chatUrl,
  });

}

