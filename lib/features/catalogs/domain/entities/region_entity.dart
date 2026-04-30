class RegionEntity {
  final int id;
  final String name;
  final int? parentId;

  const RegionEntity({
    required this.id,
    required this.name,
    this.parentId,
  });
}
