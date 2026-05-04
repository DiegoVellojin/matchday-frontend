import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../infrastructure/services/location_service.dart';
import '../../../domain/entities/cancha_entity.dart';

enum AddCourtStatus { initial, loading, success, failure }

class AddCourtState extends Equatable {
  final AddCourtStatus status;
  final List<PlaceSuggestion> suggestions;
  final LatLng? selectedPosition;
  final String selectedAddress;
  final String selectedName;
  final String errorMessage;
  final CanchaEntity? createdCancha;

  const AddCourtState({
    this.status = AddCourtStatus.initial,
    this.suggestions = const [],
    this.selectedPosition,
    this.selectedAddress = '',
    this.selectedName = '',
    this.errorMessage = '',
    this.createdCancha,
  });

  AddCourtState copyWith({
    AddCourtStatus? status,
    List<PlaceSuggestion>? suggestions,
    LatLng? selectedPosition,
    String? selectedAddress,
    String? selectedName,
    String? errorMessage,
    CanchaEntity? createdCancha,
  }) {
    return AddCourtState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedName: selectedName ?? this.selectedName,
      errorMessage: errorMessage ?? this.errorMessage,
      createdCancha: createdCancha ?? this.createdCancha,
    );
  }

  @override
  List<Object?> get props => [
        status,
        suggestions,
        selectedPosition,
        selectedAddress,
        selectedName,
        errorMessage,
        createdCancha,
      ];
}
