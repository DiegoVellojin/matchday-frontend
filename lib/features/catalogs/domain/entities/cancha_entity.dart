class CanchaEntity {
  final int id;
  final String name;
  final String? address;
  final int regionId;
  final double? latitude;
  final double? longitude;

  const CanchaEntity({
    required this.id,
    required this.name,
    this.address,
    required this.regionId,
    this.latitude,
    this.longitude,
  });
}
