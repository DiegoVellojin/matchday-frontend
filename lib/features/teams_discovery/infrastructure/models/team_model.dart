import '../../domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.logo,
    required super.sportName,
    required super.maxMembers,
    required super.currentMembers,
    required super.isRecruiting,
    required super.soyMiembro,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id_equipo'] ?? 0,
      name: json['nombre_equipo'] ?? 'Sin Nombre',
      logo: json['url_logo_equipo'] ?? '⚽', // Valor por defecto visual
      sportName: json['deporte']?['nombre_deporte'] ?? 'Deporte',
      maxMembers: json['max_miembros'] ?? 11,
      currentMembers: json['miembros_actuales'] ?? 0,
      isRecruiting: json['esta_reclutando'] ?? true,
      soyMiembro: json['soy_miembro'] ?? false,
    );

  }
}
