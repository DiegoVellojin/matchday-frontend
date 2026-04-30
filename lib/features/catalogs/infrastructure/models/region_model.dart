import '../../domain/entities/region_entity.dart';

class RegionModel extends RegionEntity {
  const RegionModel({
    required super.id,
    required super.name,
    super.parentId,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id_region'],
      name: json['nombre_region'],
      parentId: json['fk_id_region'],
    );
  }
}
