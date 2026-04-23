import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  // Aquí prepararemos el terreno para cuando FastAPI nos devuelva el JSON del usuario
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['idUsuario'].toString(),
      email: json['emailUsuario'],
      name: json['nombreUsuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': id,
      'emailUsuario': email,
      'nombreUsuario': name,
    };
  }
}