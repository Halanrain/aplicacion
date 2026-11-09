import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../theme/theme.dart';
import 'destino.dart';

// TODO: reemplaza con tu clave de API de Google (necesita Directions API activada)
const String _kGoogleApiKey = 'AIzaSyC3-bRCp1g_Z8o_gjknUR4a-lMPOyK9kLg';

class MapaView extends StatefulWidget {
  final void Function(bool)? onDestinoActivo;

  const MapaView({super.key, this.onDestinoActivo});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  static const LatLng _inicioSantiago = LatLng(-33.4489, -70.6693);
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _siguiendoUbicacion = false;

  Map<String, dynamic>? _lugarSeleccionado;
  Set<Marker> _marcadores = {};

  // Estado del viaje
  bool _viajeIniciado = false;
  Set<Polyline> _polilineas = {};
  String _distanciaRuta = '';
  String _duracionRuta = '';
  bool _cargandoRuta = false;

  @override
  void initState() {
    super.initState();
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  Future<void> _abrirBuscador() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const BuscarDestinoView()),
    );

    if (resultado != null && mounted) {
      final lat = resultado['lat'] as double;
      final lng = resultado['lng'] as double;

      setState(() {
        _lugarSeleccionado = resultado;
        _marcadores = {
          Marker(
            markerId: const MarkerId('destino'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: resultado['nombre'] as String),
          ),
        };
        _siguiendoUbicacion = false;
      });

      widget.onDestinoActivo?.call(true);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
      );
    }
  }

  void _cerrarLugar() {
    setState(() {
      _lugarSeleccionado = null;
      _marcadores = {};
      _viajeIniciado = false;
      _polilineas = {};
      _distanciaRuta = '';
      _duracionRuta = '';
    });
    widget.onDestinoActivo?.call(false);
  }

  void _detenerViaje() {
    setState(() {
      _viajeIniciado = false;
      _polilineas = {};
      _distanciaRuta = '';
      _duracionRuta = '';
    });
  }

  Future<void> _iniciarViaje() async {
    if (_lugarSeleccionado == null) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    if (permiso == LocationPermission.deniedForever) return;

    setState(() => _cargandoRuta = true);

    try {
      final posicion = await Geolocator.getCurrentPosition();
      final lat = _lugarSeleccionado!['lat'] as double;
      final lng = _lugarSeleccionado!['lng'] as double;

      // Routes API (nueva versión de Directions API)
      final url = Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      );

      final body = json.encode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': posicion.latitude,
              'longitude': posicion.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {'latitude': lat, 'longitude': lng},
          },
        },
        'travelMode': 'BICYCLE',
        'computeAlternativeRoutes': false,
        'languageCode': 'es-419',
        'units': 'METRIC',
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _kGoogleApiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
        body: body,
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data.containsKey('routes') &&
          (data['routes'] as List).isNotEmpty) {
        final route =
            (data['routes'] as List).first as Map<String, dynamic>;

        // Distancia
        final distanceMeters = route['distanceMeters'] as int;
        final distancia = distanceMeters >= 1000
            ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
            : '$distanceMeters m';

        // Duración (viene como "1380s")
        final durationStr = route['duration'] as String;
        final durationSecs =
            int.parse(durationStr.replaceAll('s', ''));
        final mins = (durationSecs / 60).round();
        final duracion = mins >= 60
            ? '${mins ~/ 60} h ${mins % 60} min'
            : '$mins min';

        // Polilínea
        final encodedPolyline =
            route['polyline']['encodedPolyline'] as String;
        final points = _decodePolyline(encodedPolyline);

        setState(() {
          _distanciaRuta = distancia;
          _duracionRuta = duracion;
          _polilineas = {
            Polyline(
              polylineId: const PolylineId('ruta'),
              points: points,
              color: AppColors.brand500,
              width: 5,
            ),
          };
          _viajeIniciado = true;
          _cargandoRuta = false;
        });

        // Ajustar cámara para mostrar toda la ruta
        final bounds = LatLngBounds(
          southwest: LatLng(
            math.min(posicion.latitude, lat),
            math.min(posicion.longitude, lng),
          ),
          northeast: LatLng(
            math.max(posicion.latitude, lat),
            math.max(posicion.longitude, lng),
          ),
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      } else {
        setState(() => _cargandoRuta = false);
      }
    } catch (_) {
      setState(() => _cargandoRuta = false);
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
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
        CameraUpdate.newLatLng(LatLng(posicion.latitude, posicion.longitude)),
      );
      setState(() => _siguiendoUbicacion = true);

      Geolocator.getPositionStream().listen((pos) {
        if (_siguiendoUbicacion && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
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
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space400,
            AppSpacing.space400,
            AppSpacing.space400,
            AppSpacing.space400 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tipo de mapa',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/icons/icon-close.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.neutral800,
                        BlendMode.srcIn,
                      ),
                    ),
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
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.neutral0,
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _inicioSantiago,
              zoom: 14,
            ),
            zoomControlsEnabled: false,
            mapType: _mapType,
            myLocationEnabled: _siguiendoUbicacion,
            myLocationButtonEnabled: false,
            markers: _marcadores,
            polylines: _polilineas,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // ── Barra de búsqueda + filtros (oculta en modo viaje) ────────
          if (!_viajeIniciado)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _abrirBuscador,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.neutral0,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: const [AppElevation.elevation1],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: AppSpacing.space400),
                            SvgPicture.asset(
                              'assets/icons/icon-search.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space200),
                            Expanded(
                              child: Text(
                                _lugarSeleccionado != null
                                    ? _lugarSeleccionado!['nombre'] as String
                                    : 'Busca un destino',
                                style: text.bodyLarge?.copyWith(
                                  color: _lugarSeleccionado != null
                                      ? AppColors.neutral800
                                      : AppColors.neutral500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const VerticalDivider(
                              width: AppSpacing.space400,
                              indent: 10,
                              endIndent: 10,
                              color: AppColors.neutral300,
                            ),
                            const SizedBox(width: AppSpacing.space200),
                            SvgPicture.asset(
                              'assets/icons/icon-timer-circle.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space200),
                            Text(
                              'Planificar',
                              style: text.bodyLarge?.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space400),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space200),

                    Row(
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space300,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: const [AppElevation.elevation1],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.directions_bike,
                                color: AppColors.accent500,
                              ),
                              SizedBox(width: AppSpacing.space100),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.neutral500,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space200),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space300,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: const [AppElevation.elevation1],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.filter_alt_outlined,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: AppSpacing.space100),
                              Text(
                                'Filtros',
                                style: text.bodyLarge?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── Barra superior modo viaje ─────────────────────────────────
          if (_viajeIniciado && _lugarSeleccionado != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra blanca "Viaje"
                  Container(
                    color: AppColors.neutral0,
                    padding: EdgeInsets.only(top: topPadding),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _detenerViaje,
                            icon: SvgPicture.asset(
                              'assets/icons/icon-back.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral800,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Viaje',
                              textAlign: TextAlign.center,
                              style: text.titleMedium?.copyWith(
                                color: AppColors.neutral800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _cerrarLugar,
                            icon: SvgPicture.asset(
                              'assets/icons/icon-close.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral800,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Barra verde con destino
                  Container(
                    color: AppColors.brand500,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space400,
                      vertical: AppSpacing.space200,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Ubicación actual',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.neutral0,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space100),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.neutral0,
                        ),
                        const SizedBox(width: AppSpacing.space100),
                        Expanded(
                          child: Text(
                            _lugarSeleccionado!['nombre'] as String,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.neutral0,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Botones GPS / capas ───────────────────────────────────────
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
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/icon-layers-map.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.neutral800,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.neutral200,
                      indent: 8,
                      endIndent: 8,
                    ),
                    InkWell(
                      onTap: _toggleUbicacion,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.full),
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/icon-gps.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              _siguiendoUbicacion
                                  ? AppColors.accent500
                                  : AppColors.neutral800,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Panel inferior ─────────────────────────────────────────────
          if (_lugarSeleccionado == null && !_viajeIniciado)
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space200),
                      Text(
                        '20 rutas',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.neutral500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          else if (_lugarSeleccionado != null && !_viajeIniciado)
            Positioned(
              bottom: AppSpacing.space400 + bottomPadding,
              left: AppSpacing.space400,
              right: AppSpacing.space400,
              child: _CardLugar(
                lugar: _lugarSeleccionado!,
                onCerrar: _cerrarLugar,
                onComenzarViaje: _iniciarViaje,
                cargando: _cargandoRuta,
              ),
            )
          else if (_viajeIniciado)
            Positioned(
              bottom: AppSpacing.space400 + bottomPadding,
              left: AppSpacing.space400,
              right: AppSpacing.space400,
              child: _CardViaje(
                distancia: _distanciaRuta,
                duracion: _duracionRuta,
                onDetener: _detenerViaje,
                onIniciar: () {
                  // TODO: implementar navegación giro a giro
                },
              ),
            ),

          // ── Loading overlay ─────────────────────────────────────────────
          if (_cargandoRuta)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brand500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Card del lugar seleccionado ───────────────────────────────────────────

class _CardLugar extends StatelessWidget {
  final Map<String, dynamic> lugar;
  final VoidCallback onCerrar;
  final VoidCallback onComenzarViaje;
  final bool cargando;

  const _CardLugar({
    required this.lugar,
    required this.onCerrar,
    required this.onComenzarViaje,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fotos = lugar['fotos'] as List<String>;
    final nombre = lugar['nombre'] as String;
    final descripcion = lugar['descripcion'] as String;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space100),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppElevation.elevation2],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.27,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xl),
                      topRight: Radius.circular(AppRadius.sm),
                      bottomLeft: Radius.circular(AppRadius.sm),
                      bottomRight: Radius.circular(AppRadius.sm),
                    ),
                    child: fotos.isNotEmpty
                        ? Image.network(
                            fotos[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.neutral200,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.neutral400,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral200,
                            child: const Icon(
                              Icons.place_outlined,
                              color: AppColors.neutral400,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space100),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.sm),
                          topRight: Radius.circular(AppRadius.xl),
                          bottomLeft: Radius.circular(AppRadius.sm),
                          bottomRight: Radius.circular(AppRadius.sm),
                        ),
                        child: fotos.length > 1
                            ? Image.network(
                                fotos[1],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.neutral300,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.neutral400,
                                  ),
                                ),
                              )
                            : Container(color: AppColors.neutral300),
                      ),
                      Positioned(
                        top: AppSpacing.space200,
                        right: AppSpacing.space200,
                        child: Row(
                          children: [
                            _BotonIcono(
                              iconPath: 'assets/icons/icon-bookmark.svg',
                              onTap: () {},
                            ),
                            const SizedBox(width: AppSpacing.space200),
                            _BotonIcono(
                              iconPath: 'assets/icons/icon-close.svg',
                              onTap: onCerrar,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space100),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space200,
              AppSpacing.space400,
              AppSpacing.space200,
              AppSpacing.space200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: AppColors.accent500,
                    ),
                    const SizedBox(width: AppSpacing.space100),
                    Expanded(
                      child: Text(
                        descripcion,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.neutral500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space100),
                Text(
                  nombre,
                  style: text.headlineSmall?.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.space100),
                Text(
                  'Recomendado por la comunidad',
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: AppSpacing.space400),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: cargando ? null : onComenzarViaje,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand500,
                      foregroundColor: AppColors.neutral0,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.neutral0,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Comenzar viaje',
                            style: text.labelLarge?.copyWith(
                              color: AppColors.neutral0,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card modo viaje ───────────────────────────────────────────────────────

class _CardViaje extends StatelessWidget {
  final String distancia;
  final String duracion;
  final VoidCallback onDetener;
  final VoidCallback onIniciar;

  const _CardViaje({
    required this.distancia,
    required this.duracion,
    required this.onDetener,
    required this.onIniciar,
  });

  /// Separa "17.0 km" → ("17.0", "km")  |  "900 m" → ("900", "m")
  static (String, String) _splitDistancia(String d) {
    if (d.isEmpty) return ('—', '');
    final parts = d.split(' ');
    return (parts.first, parts.length > 1 ? parts.last : '');
  }

  /// Separa "23 min" → ("23", "min")  |  "1 h 21 min" → ("1:21", "h")
  static (String, String) _splitDuracion(String d) {
    if (d.isEmpty) return ('—', '');
    final parts = d.split(' ');
    if (parts.length == 2) return (parts.first, parts.last);
    // "1 h 21 min"
    return ('${parts[0]}:${parts[2].padLeft(2, '0')}', 'h');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (numDist, unidDist) = _splitDistancia(distancia);
    final (numDur, unidDur) = _splitDuracion(duracion);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space400),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [AppElevation.elevation2],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mejor ruta',
            style: text.titleSmall?.copyWith(color: AppColors.neutral800),
          ),
          const SizedBox(height: AppSpacing.space300),
          Row(
            children: [
              _StatViaje(numero: '67', unidad: '%', etiqueta: 'Match'),
              _StatViaje(numero: numDist, unidad: unidDist, etiqueta: 'Distancia'),
              _StatViaje(numero: numDur, unidad: unidDur, etiqueta: 'Duración'),
            ],
          ),
          const SizedBox(height: AppSpacing.space400),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onIniciar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand500,
                      foregroundColor: AppColors.neutral0,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Iniciar',
                      style: text.labelLarge?.copyWith(
                        color: AppColors.neutral0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space200),
              _BotonCircular(
                iconPath: 'assets/icons/icon-close.svg',
                onTap: onDetener,
              ),
              const SizedBox(width: AppSpacing.space200),
              _BotonCircular(
                iconPath: 'assets/icons/icon-bookmark.svg',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatViaje extends StatelessWidget {
  final String numero;
  final String unidad;
  final String etiqueta;

  const _StatViaje({
    required this.numero,
    required this.unidad,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: numero,
                  style: text.headlineMedium?.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unidad.isNotEmpty)
                  TextSpan(
                    text: ' $unidad',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            etiqueta,
            style: text.bodySmall?.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}

// ─── Botón circular con borde (para _CardViaje) ────────────────────────────

class _BotonCircular extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _BotonCircular({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neutral200, width: 1.5),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral500,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Botón icono circular ──────────────────────────────────────────────────

class _BotonIcono extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _BotonIcono({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: const [AppElevation.elevation1],
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral800,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Selector de tipo de mapa ──────────────────────────────────────────────

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