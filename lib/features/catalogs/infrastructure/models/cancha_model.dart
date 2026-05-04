import '../../domain/entities/cancha_entity.dart';

class CanchaModel extends CanchaEntity {
  const CanchaModel({
    required super.id,
    required super.name,
    super.address,
    required super.regionId,
    super.latitude,
    super.longitude,
  });

  factory CanchaModel.fromJson(Map<String, dynamic> json) {
    return CanchaModel(
      id: json['id_cancha'],
      name: json['nombre_cancha'],
      address: json['direccion_cancha'],
      regionId: json['fk_id_region'],
      latitude: json['latitud_cancha'] != null ? double.parse(json['latitud_cancha'].toString()) : null,
      longitude: json['longitud_cancha'] != null ? double.parse(json['longitud_cancha'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id_cancha': id,
      'nombre_cancha': name,
      'direccion_cancha': address,
      'fk_id_region': regionId,
      'latitud_cancha': latitude,
      'longitud_cancha': longitude,
    };
  }
}
