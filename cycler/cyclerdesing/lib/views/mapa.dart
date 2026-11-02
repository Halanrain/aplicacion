import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/theme.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  static const LatLng _inicioSantiago = LatLng(-33.4489, -70.6693);
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _siguiendoUbicacion = false;

  @override
  void initState() {
    super.initState();
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  Future<void> _toggleUbicacion() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    if (permiso == LocationPermission.deniedForever) return;

    if (_siguiendoUbicacion) {
      setState(() => _siguiendoUbicacion = false);
    } else {
      final posicion = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(posicion.latitude, posicion.longitude),
        ),
      );
      setState(() => _siguiendoUbicacion = true);

      Geolocator.getPositionStream().listen((pos) {
        if (_siguiendoUbicacion && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(pos.latitude, pos.longitude),
            ),
          );
        }
      });
    }
  }

  void _mostrarTiposMapa() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neutral0,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.space400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tipo de mapa', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.neutral800),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space400),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MapTypeOption(
                    label: 'Estándar',
                    icon: Icons.map_outlined,
                    selected: _mapType == MapType.normal,
                    onTap: () {
                      setState(() => _mapType = MapType.normal);
                      Navigator.pop(context);
                    },
                  ),
                  _MapTypeOption(
                    label: 'Satélite',
                    icon: Icons.satellite_alt_outlined,
                    selected: _mapType == MapType.satellite,
                    onTap: () {
                      setState(() => _mapType = MapType.satellite);
                      Navigator.pop(context);
                    },
                  ),
                  _MapTypeOption(
                    label: 'Relieve',
                    icon: Icons.terrain_outlined,
                    selected: _mapType == MapType.terrain,
                    onTap: () {
                      setState(() => _mapType = MapType.terrain);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space400),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutral0,
      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _inicioSantiago,
              zoom: 14,
            ),
            zoomControlsEnabled: false,
            mapType: _mapType,
            myLocationEnabled: _siguiendoUbicacion,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.neutral0,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [AppElevation.elevation1],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.space400),
                        const Icon(Icons.search, color: AppColors.neutral500),
                        const SizedBox(width: AppSpacing.space200),
                        Expanded(
                          child: Text(
                            'Busca un destino',
                            style: text.bodyLarge?.copyWith(color: AppColors.neutral500),
                          ),
                        ),
                        const VerticalDivider(
                          width: AppSpacing.space400,
                          indent: 10,
                          endIndent: 10,
                          color: AppColors.neutral300,
                        ),
                        const SizedBox(width: AppSpacing.space200),
                        const Icon(Icons.timer_outlined, color: AppColors.neutral800),
                        const SizedBox(width: AppSpacing.space200),
                        Text('Planificar', style: text.bodyLarge?.copyWith(color: AppColors.neutral800)),
                        const SizedBox(width: AppSpacing.space400),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space200),

                  Row(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space300),
                        decoration: BoxDecoration(
                          color: AppColors.neutral0,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: const [AppElevation.elevation1],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.directions_bike, color: AppColors.accent500),
                            SizedBox(width: AppSpacing.space100),
                            Icon(Icons.keyboard_arrow_down, color: AppColors.neutral500),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space200),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space300),
                        decoration: BoxDecoration(
                          color: AppColors.neutral0,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: const [AppElevation.elevation1],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt_outlined, color: AppColors.neutral500),
                            const SizedBox(width: AppSpacing.space100),
                            Text('Filtros', style: text.bodyLarge?.copyWith(color: AppColors.neutral500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: AppSpacing.space400,
            bottom: 120,
            child: Container(
              width: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: const [AppElevation.elevation3],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    InkWell(
                      onTap: _mostrarTiposMapa,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.full),
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.layers_outlined,
                          color: AppColors.neutral800,
                          size: 20,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.neutral200, indent: 8, endIndent: 8),
                    InkWell(
                      onTap: _toggleUbicacion,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.full),
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.my_location,
                          color: _siguiendoUbicacion ? AppColors.accent500 : AppColors.neutral800,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral0,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                  boxShadow: const [AppElevation.elevation3],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.space400),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space200),
                    Text(
                      '20 rutas',
                      style: text.bodySmall?.copyWith(color: AppColors.neutral500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MapTypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? AppColors.brand500 : AppColors.neutral200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 36,
              color: selected ? AppColors.brand500 : AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.space200),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? AppColors.brand500 : AppColors.neutral800,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}