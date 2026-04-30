import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.fechaInicioEstimada,
    required super.fechaFinEstimada,
    super.fechaAcordada,
    required super.costoTotal,
    required super.estatus,
    required super.idUsuarioOrg,
    required super.idDeporte,
    required super.idCancha,
    super.idEquipoA,
    super.idEquipoB,
    super.propuestaFechaA,
    super.propuestaCostoA,
    super.propuestaFechaB,
    super.propuestaCostoB,
    super.nombreEquipoA,
    super.logoEquipoA,
    super.nombreCapitanA,
    super.nombreCancha,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      fechaInicioEstimada: DateTime.parse(json['fecha_inicio_estimada']),
      fechaFinEstimada: DateTime.parse(json['fecha_fin_estimada']),
      fechaAcordada: json['fecha_acordada'] != null 
          ? DateTime.parse(json['fecha_acordada']) 
          : null,
      costoTotal: (json['costo_total_partida'] as num).toDouble(),
      estatus: json['estatus_partida'],
      idUsuarioOrg: json['fk_id_usuario_org'],
      idDeporte: json['fk_id_deporte'],
      idCancha: json['fk_id_cancha'],
      idEquipoA: json['fk_id_equipo_a'],
      idEquipoB: json['fk_id_equipo_b'],
      propuestaFechaA: json['propuesta_fecha_a'] != null 
          ? DateTime.parse(json['propuesta_fecha_a']) 
          : null,
      propuestaCostoA: json['propuesta_costo_a'] != null 
          ? (json['propuesta_costo_a'] as num).toDouble() 
          : null,
      propuestaFechaB: json['propuesta_fecha_b'] != null 
          ? DateTime.parse(json['propuesta_fecha_b']) 
          : null,
      propuestaCostoB: json['propuesta_costo_b'] != null 
          ? (json['propuesta_costo_b'] as num).toDouble() 
          : null,
      nombreEquipoA: json['nombre_equipo_a'],
      logoEquipoA: json['logo_equipo_a'],
      nombreCapitanA: json['nombre_capitan_a'],
      nombreCancha: json['nombre_cancha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_inicio_estimada': fechaInicioEstimada.toIso8601String(),
      'fecha_fin_estimada': fechaFinEstimada.toIso8601String(),
      'fecha_acordada': fechaAcordada?.toIso8601String(),
      'costo_total_partida': costoTotal,
      'estatus_partida': estatus,
      'fk_id_usuario_org': idUsuarioOrg,
      'fk_id_deporte': idDeporte,
      'fk_id_cancha': idCancha,
      'fk_id_equipo_a': idEquipoA,
      'fk_id_equipo_b': idEquipoB,
      'propuesta_fecha_a': propuestaFechaA?.toIso8601String(),
      'propuesta_costo_a': propuestaCostoA,
      'propuesta_fecha_b': propuestaFechaB?.toIso8601String(),
      'propuesta_costo_b': propuestaCostoB,
      'nombre_equipo_a': nombreEquipoA,
      'logo_equipo_a': logoEquipoA,
      'nombre_capitan_a': nombreCapitanA,
      'nombre_cancha': nombreCancha,
    };
  }
}
