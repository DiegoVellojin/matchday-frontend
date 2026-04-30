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

  // Campos enriquecidos para visualización
  final String? nombreEquipoA;
  final String? logoEquipoA;
  final String? nombreCapitanA;
  final String? nombreCancha;
  final String? sportName;

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
    this.nombreEquipoA,
    this.logoEquipoA,
    this.nombreCapitanA,
    this.nombreCancha,
    this.sportName,
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
        nombreEquipoA,
        logoEquipoA,
        nombreCapitanA,
        nombreCancha,
        sportName,
      ];
}
