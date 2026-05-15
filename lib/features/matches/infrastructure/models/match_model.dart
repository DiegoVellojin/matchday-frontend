import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_status.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.fechaInicioEstimada,
    required super.fechaFinEstimada,
    super.fechaAcordada,
    required super.costoTotal,
    required super.status,
    required super.moneda,
    required super.idUsuarioOrg,
    required super.idDeporte,
    required super.idCancha,
    super.idEquipoA,
    super.idEquipoB,
    required super.cuposTotales,
    required super.jugadoresInscritos,
    required super.cuotaPorJugador,
    super.propuestaFechaA,
    super.propuestaCostoA,
    super.propuestaMonedaA = 'USD',
    super.propuestaFechaB,
    super.propuestaCostoB,
    super.propuestaMonedaB = 'USD',
    super.equipoAListo = false,
    super.equipoBListo = false,
    super.nombreEquipoA,
    super.logoEquipoA,
    super.nombreCapitanA,
    super.nombreCancha,
    super.sportName,
    super.idCapitanB,
    super.nombreEquipoB,
    super.logoEquipoB,
    super.telefonoCapitanA,
    super.telefonoCapitanB,
    super.resultadoGolesACapA,
    super.resultadoGolesBCapA,
    super.resultadoGolesACapB,
    super.resultadoGolesBCapB,
    super.latitudCancha,
    super.longitudCancha,
    super.bancoReceptor,
    super.cedulaReceptora,
    super.telefonoReceptor,
    super.bancoCapitanB,
    super.cedulaCapitanB,
    super.telefonoCapitanBPago,
    super.idEquipoUsuario,
    super.yaEvaluado = false,
    super.evaluaciones = const [],
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
      status: MatchStatus.fromString(json['estatus_partida']),
      moneda: json['moneda'] ?? 'USD',
      idUsuarioOrg: json['fk_id_usuario_org'],
      idDeporte: json['fk_id_deporte'],
      idCancha: json['fk_id_cancha'],
      idEquipoA: json['fk_id_equipo_a'],
      idEquipoB: json['fk_id_equipo_b'],
      cuposTotales: json['cupos_totales'] ?? 22,
      jugadoresInscritos: json['jugadores_inscritos'] ?? 0,
      cuotaPorJugador: (json['cuota_por_jugador'] as num?)?.toDouble() ?? 0.0,
      propuestaFechaA: json['propuesta_fecha_a'] != null
          ? DateTime.parse(json['propuesta_fecha_a'])
          : null,
      propuestaCostoA: json['propuesta_costo_a'] != null
          ? (json['propuesta_costo_a'] as num).toDouble()
          : null,
      propuestaMonedaA: json['propuesta_moneda_a'] ?? 'USD',
      propuestaFechaB: json['propuesta_fecha_b'] != null
          ? DateTime.parse(json['propuesta_fecha_b'])
          : null,
      propuestaCostoB: json['propuesta_costo_b'] != null
          ? (json['propuesta_costo_b'] as num).toDouble()
          : null,
      propuestaMonedaB: json['propuesta_moneda_b'] ?? 'USD',
      equipoAListo: json['equipo_a_listo'] ?? false,
      equipoBListo: json['equipo_b_listo'] ?? false,
      nombreEquipoA: json['nombre_equipo_a'],
      logoEquipoA: json['logo_equipo_a'],
      nombreCapitanA: json['nombre_capitan_a'],
      nombreCancha: json['nombre_cancha'],
      sportName: json['nombre_deporte'],
      idCapitanB: json['id_capitan_b'],
      nombreEquipoB: json['nombre_equipo_b'],
      logoEquipoB: json['logo_equipo_b'],
      telefonoCapitanA: json['telefono_capitan_a'],
      telefonoCapitanB: json['telefono_capitan_b'],
      resultadoGolesACapA: json['resultado_goles_a_cap_a'],
      resultadoGolesBCapA: json['resultado_goles_b_cap_a'],
      resultadoGolesACapB: json['resultado_goles_a_cap_b'],
      resultadoGolesBCapB: json['resultado_goles_b_cap_b'],
      latitudCancha: json['latitud_cancha'] != null
          ? (json['latitud_cancha'] as num).toDouble()
          : null,
      longitudCancha: json['longitud_cancha'] != null
          ? (json['longitud_cancha'] as num).toDouble()
          : null,
      bancoReceptor: json['banco_receptor'],
      cedulaReceptora: json['cedula_receptora'],
      telefonoReceptor: json['telefono_receptor'],
      bancoCapitanB: json['banco_capitan_b'],
      cedulaCapitanB: json['cedula_capitan_b'],
      telefonoCapitanBPago: json['telefono_capitan_b_pago'],
      idEquipoUsuario: json['id_equipo_usuario'],
      yaEvaluado: json['ya_evaluado'] ?? false,
      evaluaciones: (json['evaluaciones'] as List?)
              ?.map((e) => MatchEvaluation(
                    id: e['id_evaluacion'],
                    puntuacion: e['puntuacion'],
                    comentario: e['comentario'],
                    evaluadorNombre: e['evaluador_nombre'] ?? 'Usuario',
                    fecha: DateTime.parse(e['fecha_evaluacion']),
                  ))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_inicio_estimada': fechaInicioEstimada.toIso8601String(),
      'fecha_fin_estimada': fechaFinEstimada.toIso8601String(),
      'fecha_acordada': fechaAcordada?.toIso8601String(),
      'costo_total_partida': costoTotal,
      'estatus_partida': status.name,
      'moneda': moneda,
      'fk_id_usuario_org': idUsuarioOrg,
      'fk_id_deporte': idDeporte,
      'fk_id_cancha': idCancha,
      'fk_id_equipo_a': idEquipoA,
      'fk_id_equipo_b': idEquipoB,
      'cupos_totales': cuposTotales,
      'jugadores_inscritos': jugadoresInscritos,
      'cuota_por_jugador': cuotaPorJugador,
      'propuesta_fecha_a': propuestaFechaA?.toIso8601String(),
      'propuesta_costo_a': propuestaCostoA,
      'propuesta_moneda_a': propuestaMonedaA,
      'propuesta_fecha_b': propuestaFechaB?.toIso8601String(),
      'propuesta_costo_b': propuestaCostoB,
      'propuesta_moneda_b': propuestaMonedaB,
      'equipo_a_listo': equipoAListo,
      'equipo_b_listo': equipoBListo,
      'nombre_equipo_a': nombreEquipoA,
      'logo_equipo_a': logoEquipoA,
      'nombre_capitan_a': nombreCapitanA,
      'nombre_cancha': nombreCancha,
      'nombre_deporte': sportName,
      'id_capitan_b': idCapitanB,
      'nombre_equipo_b': nombreEquipoB,
      'logo_equipo_b': logoEquipoB,
      'telefono_capitan_a': telefonoCapitanA,
      'telefono_capitan_b': telefonoCapitanB,
      'resultado_goles_a_cap_a': resultadoGolesACapA,
      'resultado_goles_b_cap_a': resultadoGolesBCapA,
      'resultado_goles_a_cap_b': resultadoGolesACapB,
      'resultado_goles_b_cap_b': resultadoGolesBCapB,
      'latitud_cancha': latitudCancha,
      'longitud_cancha': longitudCancha,
      'banco_receptor': bancoReceptor,
      'cedula_receptora': cedulaReceptora,
      'telefono_receptor': telefonoReceptor,
      'banco_capitan_b': bancoCapitanB,
      'cedula_capitan_b': cedulaCapitanB,
      'telefono_capitan_b_pago': telefonoCapitanBPago,
    };
  }
}

class MatchPlayerModel extends MatchPlayer {
  const MatchPlayerModel({
    required super.idUsuario,
    required super.nombreUsuario,
    super.urlFotoPerfil,
    required super.estatusPago,
    super.urlReciboPago,
    super.referenciaPago,
    super.idEquipo,
    super.tasaUsadaBs,
    super.montoPagadoBs,
  });

  factory MatchPlayerModel.fromJson(Map<String, dynamic> json) {
    return MatchPlayerModel(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      urlFotoPerfil: json['url_foto_perfil'],
      estatusPago: json['estatus_pago'],
      urlReciboPago: json['url_recibo_pago'],
      referenciaPago: json['referencia_pago'],
      idEquipo: json['id_equipo'],
      tasaUsadaBs: (json['tasa_usada_bs'] as num?)?.toDouble(),
      montoPagadoBs: (json['monto_pagado_bs'] as num?)?.toDouble(),
    );
  }
}
