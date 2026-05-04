import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AddCourtEvent extends Equatable {
  const AddCourtEvent();

  @override
  List<Object?> get props => [];
}

class SearchPlacesQueryChanged extends AddCourtEvent {
  final String query;

  const SearchPlacesQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class PlaceSelected extends AddCourtEvent {
  final String placeId;

  const PlaceSelected(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class MapMarkerMoved extends AddCourtEvent {
  final LatLng position;

  const MapMarkerMoved(this.position);

  @override
  List<Object?> get props => [position];
}

class ConfirmCourtEvent extends AddCourtEvent {
  final String name;
  final String address;
  final LatLng position;
  final int regionId;

  const ConfirmCourtEvent({
    required this.name,
    required this.address,
    required this.position,
    required this.regionId,
  });

  @override
  List<Object?> get props => [name, address, position, regionId];
}
