import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/env.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}

class PlaceDetails {
  final double lat;
  final double lng;
  final String address;
  final String name;

  PlaceDetails({
    required this.lat,
    required this.lng,
    required this.address,
    required this.name,
  });
}

class LocationService {
  final Dio dio;
  final String apiKey = Env.mapsApiKey;

  LocationService({required this.dio});

  Future<List<PlaceSuggestion>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final result = response.data;
        if (result['status'] == 'OK') {
          return (result['predictions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error en Places Autocomplete: $e');
    }
    return [];
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final result = response.data;
        if (result['status'] == 'OK') {
          final location = result['result']['geometry']['location'];
          return PlaceDetails(
            lat: location['lat'],
            lng: location['lng'],
            address: result['result']['formatted_address'] ?? '',
            name: result['result']['name'] ?? 'Ubicación seleccionada',
          );
        }
      }
    } catch (e) {
      debugPrint('Error en Place Details: $e');
    }
    return null;
  }
}
