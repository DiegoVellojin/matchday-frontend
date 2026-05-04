import '../../../teams/domain/entities/sport_entity.dart';

class SportModel extends SportEntity {
  const SportModel({
    required super.id,
    required super.name,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id_deporte'],
      name: json['nombre_deporte'],
    );
  }
}
