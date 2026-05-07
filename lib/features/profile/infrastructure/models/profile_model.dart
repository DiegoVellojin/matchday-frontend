import '../../domain/entities/profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.rating,
    required super.partidosJugados,
    required super.partidosOrganizados,
    super.photoUrl,
    super.phone,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id_usuario'] ?? 0,
      name: json['nombre_usuario'] ?? 'Usuario',
      email: json['email_usuario'] ?? '',
      role: json['rol_usuario'] ?? 'Jugador',
      rating: (json['reliability_score'] ?? 5.0).toDouble(),
      partidosJugados: json['partidos_jugados'] ?? 0,
      partidosOrganizados: json['partidos_organizados'] ?? 0,
      photoUrl: json['url_foto_perfil'],
      phone: json['telefono_usuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nombre_usuario': name,
      'email_usuario': email,
      'rol_usuario': role,
      'reliability_score': rating,
      'partidos_jugados': partidosJugados,
      'partidos_organizados': partidosOrganizados,
      'url_foto_perfil': photoUrl,
      'telefono_usuario': phone,
    };
  }
}
