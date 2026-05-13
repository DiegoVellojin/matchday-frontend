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
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
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
                  heroTag: 'map_preview_fab',
                  onPressed: _openInGoogleMaps,
                  elevation: 4,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.directions_rounded, color: Colors.black),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'VER UBICACIÓN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
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
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abrir en Google Maps',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'La ubicación exacta no está configurada',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 12,
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
