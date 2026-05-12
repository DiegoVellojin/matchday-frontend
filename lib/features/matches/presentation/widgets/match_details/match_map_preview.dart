import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';

class MatchMapPreview extends StatelessWidget {
  final MatchEntity match;
  final bool isDark;

  const MatchMapPreview({
    super.key,
    required this.match,
    required this.isDark,
  });

  void _openInGoogleMaps() async {
    final query = match.nombreCancha ?? 'Cancha #${match.idCancha}';
    final url = match.latitudCancha != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=${match.latitudCancha},${match.longitudCancha}')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (match.latitudCancha != null && match.longitudCancha != null) {
      final position = LatLng(match.latitudCancha!, match.longitudCancha!);
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: position, zoom: 15),
                markers: {Marker(markerId: const MarkerId('court'), position: position)},
                liteModeEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (_) => _openInGoogleMaps(),
              ),
              PositionDetector(onTap: _openInGoogleMaps),
              Positioned(
                bottom: 12,
                right: 12,
                child: FloatingActionButton.small(
                  onPressed: _openInGoogleMaps,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.directions, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _openInGoogleMaps,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 48),
            SizedBox(height: 8),
            Text(
              'Abrir en Google Maps',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionDetector extends StatelessWidget {
  final VoidCallback onTap;
  const PositionDetector({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
