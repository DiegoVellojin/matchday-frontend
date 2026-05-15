import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int puntuacion;
  final String? comentario;
  final DateTime fecha;
  final ReviewerInfo evaluator;
  final TeamReviewInfo evaluatorTeam;

  const ReviewEntity({
    required this.id,
    required this.puntuacion,
    this.comentario,
    required this.fecha,
    required this.evaluator,
    required this.evaluatorTeam,
  });

  @override
  List<Object?> get props => [id, puntuacion, comentario, fecha, evaluator, evaluatorTeam];
}

class ReviewerInfo extends Equatable {
  final String nombre;
  final String? foto;

  const ReviewerInfo({required this.nombre, this.foto});

  @override
  List<Object?> get props => [nombre, foto];
}

class TeamReviewInfo extends Equatable {
  final String nombre;
  final String? logo;

  const TeamReviewInfo({required this.nombre, this.logo});

  @override
  List<Object?> get props => [nombre, logo];
}
