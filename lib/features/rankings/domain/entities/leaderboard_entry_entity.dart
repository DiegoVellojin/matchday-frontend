class LeaderboardEntryEntity {
  final int posicion;
  final int idEquipo;
  final String nombreEquipo;
  final String? urlLogoEquipo;
  final String deporte;
  final int puntosTotales;
  final int partidosJugados;
  final int victorias;
  final int empates;
  final int derrotas;

  LeaderboardEntryEntity({
    required this.posicion,
    required this.idEquipo,
    required this.nombreEquipo,
    this.urlLogoEquipo,
    required this.deporte,
    required this.puntosTotales,
    required this.partidosJugados,
    required this.victorias,
    required this.empates,
    required this.derrotas,
  });

  factory LeaderboardEntryEntity.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryEntity(
      posicion: json['posicion'],
      idEquipo: json['id_equipo'],
      nombreEquipo: json['nombre_equipo'],
      urlLogoEquipo: json['url_logo_equipo'],
      deporte: json['deporte'] ?? 'Desconocido',
      puntosTotales: json['puntos_totales'],
      partidosJugados: json['partidos_jugados'],
      victorias: json['victorias'],
      empates: json['empates'],
      derrotas: json['derrotas'],
    );
  }
}
