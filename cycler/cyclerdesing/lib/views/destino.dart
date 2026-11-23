import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/theme.dart';

const String _apiKey = 'AIzaSyC3-bRCp1g_Z8o_gjknUR4a-lMPOyK9kLg';

class BuscarDestinoView extends StatefulWidget {
  const BuscarDestinoView({super.key});
  @override
  State<BuscarDestinoView> createState() => _BuscarDestinoViewState();
}

class _BuscarDestinoViewState extends State<BuscarDestinoView> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _sugerencias = [];
  bool _cargando = false;

  // ── Referencia a la subcolección del usuario actual ──────────────────
  CollectionReference<Map<String, dynamic>>? get _busquedasRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('busquedas_recientes');
  }

  // ── Guardar / actualizar búsqueda (Create + Update) ──────────────────
  Future<void> _guardarBusqueda(Map<String, dynamic> lugar) async {
    final ref = _busquedasRef;
    if (ref == null) return;
    final placeId = lugar['placeId'] as String;
    if (placeId.isEmpty) return;

    await ref.doc(placeId).set({
      'nombre': lugar['nombre'],
      'descripcion': lugar['descripcion'],
      'placeId': placeId,
      'lat': lugar['lat'],
      'lng': lugar['lng'],
      'fotos': lugar['fotos'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Mantener máximo 5: eliminar los más antiguos si hay más de 5
    final snap = await ref.orderBy('timestamp', descending: true).get();
    if (snap.docs.length > 5) {
      for (final doc in snap.docs.skip(5)) {
        await doc.reference.delete();
      }
    }
  }

  // ── Eliminar búsqueda (Delete) ────────────────────────────────────────
  Future<void> _eliminarBusqueda(String placeId) async {
    await _busquedasRef?.doc(placeId).delete();
  }

  // ── Autocompletar con Places API ──────────────────────────────────────
  Future<void> _buscar(String texto) async {
    if (texto.isEmpty) {
      setState(() => _sugerencias = []);
      return;
    }

    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final respuesta = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
      },
      body: json.encode({
        'input': texto,
        'languageCode': 'es',
        'includedRegionCodes': ['cl'],
      }),
    );

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      final sugerencias = data['suggestions'] as List? ?? [];
      setState(() {
        _sugerencias = sugerencias.map((s) {
          final pred = s['placePrediction'];
          final principal =
              pred['structuredFormat']?['mainText']?['text'] as String? ?? '';
          final secundario =
              pred['structuredFormat']?['secondaryText']?['text'] as String? ??
              '';
          final placeId = pred['placeId'] as String? ?? '';
          return {
            'principal': principal,
            'secundario': secundario,
            'placeId': placeId,
          };
        }).toList();
      });
    }
  }

  // ── Seleccionar lugar desde sugerencias ───────────────────────────────
  Future<void> _seleccionarLugar(
    String placeId,
    String nombre,
    String secundario,
  ) async {
    if (placeId.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _cargando = true);

    try {
      final uri = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
      final respuesta = await http.get(
        uri,
        headers: {
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask':
              'id,displayName,location,photos,primaryTypeDisplayName',
        },
      );

      if (respuesta.statusCode == 200 && mounted) {
        final data = json.decode(respuesta.body);
        final location = data['location'];
        final lat = (location['latitude'] as num).toDouble();
        final lng = (location['longitude'] as num).toDouble();

        final fotos = ((data['photos'] as List? ?? [])
            .take(2)
            .map(
              (p) =>
                  'https://places.googleapis.com/v1/${p['name']}/media?maxWidthPx=800&key=$_apiKey',
            )
            .toList());

        final tipo = data['primaryTypeDisplayName']?['text'] as String? ?? '';
        final descripcion =
            tipo.isNotEmpty ? '$tipo · $secundario' : secundario;

        final lugar = {
          'nombre': nombre,
          'descripcion': descripcion,
          'placeId': placeId,
          'lat': lat,
          'lng': lng,
          'fotos': List<String>.from(fotos),
        };

        // Navegar inmediatamente — el guardado en Firestore va en segundo plano
        if (mounted) Navigator.pop(context, lugar);

        // Guardar sin bloquear la navegación (si falla, no importa)
        unawaited(_guardarBusqueda(lugar).catchError((_) {}));
      } else if (mounted) {
        setState(() => _cargando = false);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargando = false);
        Navigator.pop(context);
      }
    }
  }

  // ── Seleccionar lugar desde búsquedas recientes ───────────────────────
  void _seleccionarReciente(Map<String, dynamic> datos) {
    Navigator.pop(context, {
      'nombre': datos['nombre'],
      'descripcion': datos['descripcion'],
      'placeId': datos['placeId'],
      'lat': (datos['lat'] as num).toDouble(),
      'lng': (datos['lng'] as num).toDouble(),
      'fotos': List<String>.from(datos['fotos'] ?? []),
    });

    // Actualizar timestamp (lo lleva al tope) — fire-and-forget
    _busquedasRef?.doc(datos['placeId'] as String).update({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Barra de búsqueda ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space400),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neutral0,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.brand500,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.neutral800,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Busca lugares o rutas',
                              hintStyle: text.bodyLarge?.copyWith(
                                color: AppColors.neutral500,
                              ),
                              border: InputBorder.none,
                            ),
                            style: text.bodyLarge?.copyWith(
                              color: AppColors.neutral800,
                            ),
                            onChanged: _buscar,
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.neutral500,
                            ),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _sugerencias = []);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Contenido principal ───────────────────────────────
                Expanded(
                  child: _sugerencias.isEmpty
                      ? _EstadoInicial(
                          text: text,
                          busquedasRef: _busquedasRef,
                          onSeleccionarReciente: _seleccionarReciente,
                          onEliminarReciente: _eliminarBusqueda,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space400,
                          ),
                          itemCount: _sugerencias.length,
                          itemBuilder: (context, index) {
                            final lugar = _sugerencias[index];
                            return ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -2),
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.neutral500,
                              ),
                              title: Text(
                                lugar['principal'] ?? '',
                                style: text.bodyLarge,
                              ),
                              subtitle: Text(
                                lugar['secundario'] ?? '',
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                              onTap: () => _seleccionarLugar(
                                lugar['placeId'] ?? '',
                                lugar['principal'] ?? '',
                                lugar['secundario'] ?? '',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── Overlay de carga ──────────────────────────────────────────
          if (_cargando)
            Container(
              color: AppColors.neutral800.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.brand500),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Estado inicial (sin texto en buscador) ────────────────────────────────

class _EstadoInicial extends StatelessWidget {
  final TextTheme text;
  final CollectionReference<Map<String, dynamic>>? busquedasRef;
  final void Function(Map<String, dynamic>) onSeleccionarReciente;
  final Future<void> Function(String) onEliminarReciente;

  const _EstadoInicial({
    required this.text,
    required this.busquedasRef,
    required this.onSeleccionarReciente,
    required this.onEliminarReciente,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space400),
      children: [
        // Accesos rápidos fijos
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.accent500),
          ),
          title: Text('Comienza desde casa', style: text.bodyLarge),
          subtitle: Text(
            'Morande 626',
            style: text.bodyMedium?.copyWith(color: AppColors.neutral500),
          ),
          onTap: () {},
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brand500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.navigation, color: AppColors.brand500),
          ),
          title: Text(
            'Viajes desde tu ubicación actual',
            style: text.bodyLarge,
          ),
          onTap: () {},
        ),

        const SizedBox(height: AppSpacing.space400),

        // ── Búsquedas recientes (Read desde Firestore) ──────────────
        Text(
          'Búsquedas recientes',
          style: text.titleSmall?.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.space200),

        if (busquedasRef == null)
          const SizedBox.shrink()
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: busquedasRef!
                .orderBy('timestamp', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.space400),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brand500,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space400,
                  ),
                  child: Text(
                    'Aún no tienes búsquedas recientes.',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: docs.map((doc) {
                  final datos = doc.data();
                  final nombre = datos['nombre'] as String? ?? '';
                  final descripcion = datos['descripcion'] as String? ?? '';
                  final placeId = datos['placeId'] as String? ?? '';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.neutral500,
                      ),
                    ),
                    title: Text(nombre, style: text.bodyLarge),
                    subtitle: Text(
                      descripcion,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.neutral500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.neutral400,
                      ),
                      onPressed: () => onEliminarReciente(placeId),
                      tooltip: 'Eliminar búsqueda',
                    ),
                    onTap: () => onSeleccionarReciente(datos),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}