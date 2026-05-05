import 'package:equatable/equatable.dart';

class BankDetailsModel extends Equatable {
  final int idDatos;
  final int idUsuario;
  final String banco;
  final String cedula;
  final String telefono;

  const BankDetailsModel({
    required this.idDatos,
    required this.idUsuario,
    required this.banco,
    required this.cedula,
    required this.telefono,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      idDatos: json['id_datos'],
      idUsuario: json['fk_id_usuario'],
      banco: json['banco'],
      cedula: json['cedula'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_datos': idDatos,
      'fk_id_usuario': idUsuario,
      'banco': banco,
      'cedula': cedula,
      'telefono': telefono,
    };
  }

  @override
  List<Object?> get props => [idDatos, idUsuario, banco, cedula, telefono];
}
