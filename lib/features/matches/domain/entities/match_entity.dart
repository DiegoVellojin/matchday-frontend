import 'package:equatable/equatable.dart';

class MatchEntity extends Equatable {
  final int id;
  final DateTime fechaInicioEstimada;
  final DateTime fechaFinEstimada;
  final DateTime? fechaAcordada;
  final double costoTotal;
  final String estatus;
  final int idUsuarioOrg;
  final int idDeporte;
  final int idCancha;
  final int? idEquipoA;
  final int? idEquipoB;

  // Propuestas de negociación
  final DateTime? propuestaFechaA;
  final double? propuestaCostoA;
  final DateTime? propuestaFechaB;
  final double? propuestaCostoB;

  final bool equipoAListo;
  final bool equipoBListo;

  // Campos enriquecidos para visualización
  final String? nombreEquipoA;
  final String? logoEquipoA;
  final String? nombreCapitanA;
  final String? nombreCancha;
  final String? sportName;
  final int? idCapitanB;
  final String? nombreEquipoB;
  final String? logoEquipoB;

  const MatchEntity({
    required this.id,
    required this.fechaInicioEstimada,
    required this.fechaFinEstimada,
    this.fechaAcordada,
    required this.costoTotal,
    required this.estatus,
    required this.idUsuarioOrg,
    required this.idDeporte,
    required this.idCancha,
    this.idEquipoA,
    this.idEquipoB,
    this.propuestaFechaA,
    this.propuestaCostoA,
    this.propuestaFechaB,
    this.propuestaCostoB,
    this.equipoAListo = false,
    this.equipoBListo = false,
    this.nombreEquipoA,
    this.logoEquipoA,
    this.nombreCapitanA,
    this.nombreCancha,
    this.sportName,
    this.idCapitanB,
    this.nombreEquipoB,
    this.logoEquipoB,
  });

  @override
  List<Object?> get props => [
        id,
        fechaInicioEstimada,
        fechaFinEstimada,
        fechaAcordada,
        costoTotal,
        estatus,
        idUsuarioOrg,
        idDeporte,
        idCancha,
        idEquipoA,
        idEquipoB,
        propuestaFechaA,
        propuestaCostoA,
        propuestaFechaB,
        propuestaCostoB,
        equipoAListo,
        equipoBListo,
        nombreEquipoA,
        logoEquipoA,
        nombreCapitanA,
        nombreCancha,
        sportName,
        idCapitanB,
        nombreEquipoB,
        logoEquipoB,
      ];
}

class MatchPlayer extends Equatable {
  final int idUsuario;
  final String nombreUsuario;
  final String? urlFotoPerfil;
  final String estatusPago;
  final String? urlReciboPago;
  final int? idEquipo;

  const MatchPlayer({
    required this.idUsuario,
    required this.nombreUsuario,
    this.urlFotoPerfil,
    required this.estatusPago,
    this.urlReciboPago,
    this.idEquipo,
  });

  @override
  List<Object?> get props => [
        idUsuario,
        nombreUsuario,
        urlFotoPerfil,
        estatusPago,
        urlReciboPago,
        idEquipo,
      ];
}
