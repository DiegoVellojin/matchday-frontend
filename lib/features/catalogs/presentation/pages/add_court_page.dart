import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/add_court/add_court_bloc.dart';
import '../bloc/add_court/add_court_event.dart';
import '../bloc/add_court/add_court_state.dart';
import 'dart:async';

class AddCourtPage extends StatefulWidget {
  final int regionId;

  const AddCourtPage({super.key, required this.regionId});

  @override
  State<AddCourtPage> createState() => _AddCourtPageState();
}

class _AddCourtPageState extends State<AddCourtPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  Timer? _debounce;

  // Ubicación por defecto (puede ser el centro de la ciudad de la región)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.4806, -66.9036), // Caracas, Venezuela (Ejemplo)
    zoom: 12,
  );

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<AddCourtBloc>().add(SearchPlacesQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AddCourtBloc, AddCourtState>(
      listener: (context, state) async {
        if (state.status == AddCourtStatus.success && state.createdCancha != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cancha añadida correctamente'), backgroundColor: AppColors.primary),
          );
          context.pop(state.createdCancha);
        } else if (state.status == AddCourtStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
          );
        }

        // Mover cámara si se seleccionó una posición
        if (state.selectedPosition != null) {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: state.selectedPosition!, zoom: 16),
          ));
          if (_nameController.text.isEmpty && state.selectedName.isNotEmpty) {
            _nameController.text = state.selectedName;
          }
          if (_searchController.text.isEmpty && state.selectedAddress.isNotEmpty) {
             _searchController.text = state.selectedAddress;
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.background : Colors.white,
          appBar: AppBar(
            title: const Text('Añadir Cancha', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: isDark ? AppColors.background : Colors.white,
            elevation: 0,
            foregroundColor: isDark ? Colors.white : Colors.black,
          ),
          body: Stack(
            children: [
              // Google Map
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng position) {
                  context.read<AddCourtBloc>().add(MapMarkerMoved(position));
                },
                markers: state.selectedPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected_court'),
                          position: state.selectedPosition!,
                          draggable: true,
                          onDragEnd: (newPosition) {
                            context.read<AddCourtBloc>().add(MapMarkerMoved(newPosition));
                          },
                        ),
                      }
                    : {},
              ),

              // Buscador Superior
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Buscar lugar o dirección...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (state.suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = state.suggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: AppColors.primary),
                              title: Text(suggestion.description, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              onTap: () {
                                context.read<AddCourtBloc>().add(PlaceSelected(suggestion.placeId));
                                FocusScope.of(context).unfocus(); // Cerrar teclado
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Loading overlay
              if (state.status == AddCourtStatus.loading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: state.selectedPosition != null
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Cancha',
                          labelStyle: const TextStyle(color: AppColors.primary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF252525) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Debes asignarle un nombre a la cancha')),
                              );
                              return;
                            }
                            context.read<AddCourtBloc>().add(ConfirmCourtEvent(
                              name: _nameController.text.trim(),
                              address: state.selectedAddress,
                              position: state.selectedPosition!,
                              regionId: widget.regionId,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Confirmar Cancha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
