import 'dart:convert';
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
      headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': _apiKey},
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

        final tipo =
            data['primaryTypeDisplayName']?['text'] as String? ?? '';
        final descripcion =
            tipo.isNotEmpty ? '$tipo · $secundario' : secundario;

        Navigator.pop(context, {
          'nombre': nombre,
          'descripcion': descripcion,
          'lat': lat,
          'lng': lng,
          'fotos': List<String>.from(fotos),
        });
      } else if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
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
                Expanded(
                  child: _sugerencias.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space400,
                          ),
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accent500.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.home_outlined,
                                  color: AppColors.accent500,
                                ),
                              ),
                              title: Text(
                                'Comienza desde casa',
                                style: text.bodyLarge,
                              ),
                              subtitle: Text(
                                'Morande 626',
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                              onTap: () {},
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.brand500.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.navigation,
                                  color: AppColors.brand500,
                                ),
                              ),
                              title: Text(
                                'Viajes desde tu ubicación actual',
                                style: text.bodyLarge,
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(height: AppSpacing.space400),
                            Text(
                              'Búsquedas recientes',
                              style: text.titleSmall?.copyWith(
                                color: AppColors.neutral800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space200),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accent500.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.landscape_outlined,
                                  color: AppColors.accent500,
                                ),
                              ),
                              title: Text(
                                'Cerro Santa Lucía',
                                style: text.bodyLarge,
                              ),
                              subtitle: Text(
                                'Sitio histórico, Chile',
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                              onTap: () {},
                            ),
                          ],
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

          // Overlay de carga mientras se obtienen detalles del lugar
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