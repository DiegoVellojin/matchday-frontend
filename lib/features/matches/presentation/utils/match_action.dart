import 'package:flutter/material.dart';

/// Representa la acción resuelta para el botón CTA de una tarjeta de partido.
class MatchAction {
  final String label;
  final VoidCallback onTap;

  const MatchAction({required this.label, required this.onTap});
}
