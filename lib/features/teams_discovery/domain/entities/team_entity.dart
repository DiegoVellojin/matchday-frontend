class TeamEntity {
  final int id;
  final String name;
  final String logo;
  final String sportName;
  final int maxMembers;
  final int currentMembers;
  final bool isRecruiting;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.logo,
    required this.sportName,
    required this.maxMembers,
    required this.currentMembers,
    required this.isRecruiting,
  });
}
