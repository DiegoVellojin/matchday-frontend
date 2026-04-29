import '../../domain/entities/my_team_entity.dart';

/// Modelo de datos que mapea la respuesta JSON de la API hacia la entidad pura de Dominio.
class MyTeamModel extends MyTeamEntity {
  const MyTeamModel({
    required super.id,
    required super.name,
    required super.logo,
    required super.sportName,
    required super.maxMembers,
    required super.currentMembers,
    required super.isRecruiting,
    super.captainId,
    super.urlChatEquipo,
  });


  /// Crea una instancia del modelo desde un mapa de JSON.
  factory MyTeamModel.fromJson(Map<String, dynamic> json) {
    return MyTeamModel(
      id: json['id_equipo'] ?? 0,
      name: json['nombre_equipo'] ?? 'Sin Nombre',
      logo: json['url_logo_equipo'] ?? '⚽',
      sportName: json['deporte']?['nombre_deporte'] ?? 'Fútbol',
      maxMembers: json['max_miembros'] ?? 11,
      currentMembers: json['miembros_actuales'] ?? 0,
      isRecruiting: json['esta_reclutando'] ?? false,
      captainId: json['fk_id_usuario_capitan'],
      urlChatEquipo: json['url_chat_equipo'],

    );
  }
}
