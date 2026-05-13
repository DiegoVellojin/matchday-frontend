import 'package:equatable/equatable.dart';
import 'match_status.dart';

class MatchEntity extends Equatable {
  final int id;
  final DateTime fechaInicioEstimada;
  final DateTime fechaFinEstimada;
  final DateTime? fechaAcordada;
  final double costoTotal;
  final MatchStatus status;
  final String moneda;
  final int idUsuarioOrg;
  final int idDeporte;
  final int idCancha;
  final int? idEquipoA;
  final int? idEquipoB;
  final int cuposTotales;
  final int jugadoresInscritos;
  final double cuotaPorJugador;

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
  final String? telefonoCapitanA;
  final String? telefonoCapitanB;
  final int? resultadoGolesACapA;
  final int? resultadoGolesBCapA;
  final int? resultadoGolesACapB;
  final int? resultadoGolesBCapB;
  final double? latitudCancha;
  final double? longitudCancha;
  final String? bancoReceptor;
  final String? cedulaReceptora;
  final String? telefonoReceptor;
  final String? bancoCapitanB;
  final String? cedulaCapitanB;
  final String? telefonoCapitanBPago;

  const MatchEntity({
    required this.id,
    required this.fechaInicioEstimada,
    required this.fechaFinEstimada,
    this.fechaAcordada,
    required this.costoTotal,
    required this.status,
    this.moneda = 'USD',
    required this.idUsuarioOrg,
    required this.idDeporte,
    required this.idCancha,
    this.idEquipoA,
    this.idEquipoB,
    required this.cuposTotales,
    required this.jugadoresInscritos,
    required this.cuotaPorJugador,
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
    this.telefonoCapitanA,
    this.telefonoCapitanB,
    this.resultadoGolesACapA,
    this.resultadoGolesBCapA,
    this.resultadoGolesACapB,
    this.resultadoGolesBCapB,
    this.latitudCancha,
    this.longitudCancha,
    this.bancoReceptor,
    this.cedulaReceptora,
    this.telefonoReceptor,
    this.bancoCapitanB,
    this.cedulaCapitanB,
    this.telefonoCapitanBPago,
  });

  /// Getter de compatibilidad para evitar romper código existente que use '.estatus'
  String get estatus => status.name;

  @override
  List<Object?> get props => [
        id,
        fechaInicioEstimada,
        fechaFinEstimada,
        fechaAcordada,
        costoTotal,
        status,
        moneda,
        idUsuarioOrg,
        idDeporte,
        idCancha,
        idEquipoA,
        idEquipoB,
        cuposTotales,
        cuotaPorJugador,
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
        telefonoCapitanA,
        telefonoCapitanB,
        resultadoGolesACapA,
        resultadoGolesBCapA,
        resultadoGolesACapB,
        resultadoGolesBCapB,
        latitudCancha,
        longitudCancha,
        bancoReceptor,
        cedulaReceptora,
        telefonoReceptor,
        bancoCapitanB,
        cedulaCapitanB,
        telefonoCapitanBPago,
      ];
}

class MatchPlayer extends Equatable {
  final int idUsuario;
  final String nombreUsuario;
  final String? urlFotoPerfil;
  final String estatusPago;
  final String? urlReciboPago;
  final String? referenciaPago;
  final int? idEquipo;

  const MatchPlayer({
    required this.idUsuario,
    required this.nombreUsuario,
    this.urlFotoPerfil,
    required this.estatusPago,
    this.urlReciboPago,
    this.referenciaPago,
    this.idEquipo,
  });

  @override
  List<Object?> get props => [
        idUsuario,
        nombreUsuario,
        urlFotoPerfil,
        estatusPago,
        urlReciboPago,
        referenciaPago,
        idEquipo,
      ];
}
