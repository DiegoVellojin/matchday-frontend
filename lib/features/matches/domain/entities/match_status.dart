import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Representa el estado de un partido siguiendo el patrón State.
/// Cada subclase define sus propias propiedades visuales y lógica.
abstract class MatchStatus {
  final String name;
  final Color color;
  final String label;
  final IconData icon;

  const MatchStatus({
    required this.name,
    required this.color,
    required this.label,
    required this.icon,
  });

  /// Factory para crear el estado correcto a partir de un String de la DB.
  factory MatchStatus.fromString(String status) {
    switch (status) {
      case 'publicada':
        return const PublishedStatus();
      case 'negociando':
        return const NegotiatingStatus();
      case 'pendiente_pago':
        return const PendingPaymentStatus();
      case 'confirmada':
        return const ConfirmedStatus();
      case 'completada':
        return const CompletedStatus();
      case 'cancelada':
        return const CancelledStatus();
      default:
        return const UnknownStatus();
    }
  }

  // Helpers para evitar comparaciones de strings en la UI
  bool get isPublished => this is PublishedStatus;
  bool get isNegotiating => this is NegotiatingStatus;
  bool get isPendingPayment => this is PendingPaymentStatus;
  bool get isConfirmed => this is ConfirmedStatus;
  bool get isCompleted => this is CompletedStatus;
  bool get isCancelled => this is CancelledStatus;
}

class PublishedStatus extends MatchStatus {
  const PublishedStatus() : super(
    name: 'publicada',
    color: Colors.blueAccent,
    label: 'Publicada',
    icon: Icons.public,
  );
}

class NegotiatingStatus extends MatchStatus {
  const NegotiatingStatus() : super(
    name: 'negociando',
    color: Colors.orangeAccent,
    label: 'Negociando',
    icon: Icons.handshake_outlined,
  );
}

class PendingPaymentStatus extends MatchStatus {
  const PendingPaymentStatus() : super(
    name: 'pendiente_pago',
    color: Colors.amber,
    label: 'Pago Pendiente',
    icon: Icons.payments_outlined,
  );
}

class ConfirmedStatus extends MatchStatus {
  const ConfirmedStatus() : super(
    name: 'confirmada',
    color: AppColors.primary,
    label: 'Confirmada',
    icon: Icons.check_circle_outline,
  );
}

class CompletedStatus extends MatchStatus {
  const CompletedStatus() : super(
    name: 'completada',
    color: Colors.greenAccent,
    label: 'Finalizada',
    icon: Icons.emoji_events_outlined,
  );
}

class CancelledStatus extends MatchStatus {
  const CancelledStatus() : super(
    name: 'cancelada',
    color: Colors.redAccent,
    label: 'Cancelada',
    icon: Icons.cancel_outlined,
  );
}

class UnknownStatus extends MatchStatus {
  const UnknownStatus() : super(
    name: 'unknown',
    color: Colors.grey,
    label: 'Desconocido',
    icon: Icons.help_outline,
  );
}
