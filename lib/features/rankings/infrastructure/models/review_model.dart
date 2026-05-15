import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.puntuacion,
    super.comentario,
    required super.fecha,
    required super.evaluator,
    required super.evaluatorTeam,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id_evaluacion'],
      puntuacion: json['puntuacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
      evaluator: ReviewerInfo(
        nombre: json['evaluador']['nombre'],
        foto: json['evaluador']['foto'],
      ),
      evaluatorTeam: TeamReviewInfo(
        nombre: json['equipo_evaluador']['nombre'],
        logo: json['equipo_evaluador']['logo'],
      ),
    );
  }
}
