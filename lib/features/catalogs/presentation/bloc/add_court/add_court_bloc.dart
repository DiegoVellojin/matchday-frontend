import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_court_event.dart';
import 'add_court_state.dart';
import '../../../infrastructure/services/location_service.dart';
import '../../../application/usecases/create_cancha_usecase.dart';
import '../../../domain/entities/cancha_entity.dart';

class AddCourtBloc extends Bloc<AddCourtEvent, AddCourtState> {
  final LocationService locationService;
  final CreateCanchaUseCase createCanchaUseCase;

  AddCourtBloc({
    required this.locationService,
    required this.createCanchaUseCase,
  }) : super(const AddCourtState()) {
    on<SearchPlacesQueryChanged>(_onSearchQueryChanged);
    on<PlaceSelected>(_onPlaceSelected);
    on<MapMarkerMoved>(_onMapMarkerMoved);
    on<ConfirmCourtEvent>(_onConfirmCourt);
  }

  Future<void> _onSearchQueryChanged(
      SearchPlacesQueryChanged event, Emitter<AddCourtState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(suggestions: []));
      return;
    }
    
    final suggestions = await locationService.getSuggestions(event.query);
    emit(state.copyWith(suggestions: suggestions));
  }

  Future<void> _onPlaceSelected(
      PlaceSelected event, Emitter<AddCourtState> emit) async {
    emit(state.copyWith(status: AddCourtStatus.loading));
    
    final details = await locationService.getPlaceDetails(event.placeId);
    if (details != null) {
      emit(state.copyWith(
        status: AddCourtStatus.initial,
        selectedPosition: LatLng(details.lat, details.lng),
        selectedAddress: details.address,
        selectedName: details.name,
        suggestions: [], // Limpiar sugerencias
      ));
    } else {
      emit(state.copyWith(
        status: AddCourtStatus.failure,
        errorMessage: 'No se pudo obtener el detalle del lugar',
      ));
    }
  }

  void _onMapMarkerMoved(MapMarkerMoved event, Emitter<AddCourtState> emit) {
    emit(state.copyWith(selectedPosition: event.position));
  }

  Future<void> _onConfirmCourt(
      ConfirmCourtEvent event, Emitter<AddCourtState> emit) async {
    emit(state.copyWith(status: AddCourtStatus.loading));

    final cancha = CanchaEntity(
      id: 0,
      name: event.name,
      address: event.address,
      regionId: event.regionId,
      latitude: event.position.latitude,
      longitude: event.position.longitude,
    );

    final result = await createCanchaUseCase(cancha);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddCourtStatus.failure,
        errorMessage: failure.message,
      )),
      (createdCancha) => emit(state.copyWith(
        status: AddCourtStatus.success,
        createdCancha: createdCancha,
      )),
    );
  }
}
