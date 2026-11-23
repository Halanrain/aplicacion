import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme.dart';

class EditorPerfilView extends StatefulWidget {
  const EditorPerfilView({super.key});

  @override
  State<EditorPerfilView> createState() => _EditorPerfilViewState();
}

class _EditorPerfilViewState extends State<EditorPerfilView> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _picker = ImagePicker();

  File? _nuevaFoto;
  String _fotoActualUrl = '';
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _cargando = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null && mounted) {
      _nombreController.text = data['nombre'] as String? ?? '';
      _apellidoController.text = data['apellido'] as String? ?? '';
      _fotoActualUrl = data['foto'] as String? ?? '';
    }
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _seleccionarFoto(ImageSource fuente) async {
    Navigator.pop(context); // Cierra el bottom sheet
    final picked = await _picker.pickImage(
      source: fuente,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      setState(() => _nuevaFoto = File(picked.path));
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        top: false,
        child: Container(
        decoration: const BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space500,
          AppSpacing.space300,
          AppSpacing.space500,
          AppSpacing.space500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill indicador
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.space500),
            Text(
              'Cambiar foto de perfil',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: AppSpacing.space500),
            _OpcionFoto(
              icono: Icons.photo_library_outlined,
              label: 'Elegir de la galería',
              onTap: () => _seleccionarFoto(ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.space300),
            _OpcionFoto(
              icono: Icons.camera_alt_outlined,
              label: 'Tomar una foto',
              onTap: () => _seleccionarFoto(ImageSource.camera),
            ),
          ],
        ),
        ), // cierre SafeArea
      ),
    );
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      String fotoUrl = _fotoActualUrl;

      if (_nuevaFoto != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('usuarios/$uid/foto_perfil.jpg');
        await ref.putFile(_nuevaFoto!);
        fotoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({
        'nombre': nombre,
        'apellido': apellido,
        'foto': fotoUrl,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar perfil',
          style: AppTypography.subtitle1.copyWith(
            color: AppColors.neutral800,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brand500),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space500,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.space700),

                        // ── Avatar centrado ──────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _mostrarOpcionesFoto,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.neutral100,
                                    border: Border.all(
                                      color: AppColors.brand500,
                                      width: 2,
                                    ),
                                    boxShadow: const [AppElevation.elevation2],
                                  ),
                                  child: ClipOval(
                                    child: _nuevaFoto != null
                                        ? Image.file(
                                            _nuevaFoto!,
                                            fit: BoxFit.cover,
                                          )
                                        : _fotoActualUrl.isNotEmpty
                                            ? Image.network(
                                                _fotoActualUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        const Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color:
                                                        AppColors.neutral400,
                                                  ),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: AppColors.neutral400,
                                                ),
                                              ),
                                  ),
                                ),
                                // Botón naranja de editar
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent500,
                                      shape: BoxShape.circle,
                                      boxShadow: [AppElevation.elevation2],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: AppColors.neutral0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Texto indicador si hay nueva foto
                        if (_nuevaFoto != null) ...[
                          const SizedBox(height: AppSpacing.space200),
                          Center(
                            child: Text(
                              'Nueva foto lista para guardar',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.brand500,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: AppSpacing.space200),
                          Center(
                            child: Text(
                              'Toca la foto para cambiarla',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.space700),

                        // ── Sección de campos ────────────────────────────
                        Text(
                          'INFORMACIÓN PERSONAL',
                          style: AppTypography.overline.copyWith(
                            color: AppColors.neutral500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space300),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: const [AppElevation.elevation1],
                          ),
                          child: Column(
                            children: [
                              _CampoTexto(
                                controller: _nombreController,
                                label: 'Nombre',
                                hint: 'Tu nombre',
                                isFirst: true,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.neutral100,
                                indent: AppSpacing.space400,
                                endIndent: AppSpacing.space400,
                              ),
                              _CampoTexto(
                                controller: _apellidoController,
                                label: 'Apellido',
                                hint: 'Tu apellido',
                                isFirst: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Botón guardar fijo al fondo ──────────────────────────
                SafeArea(
                  top: false,
                  child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space500,
                    AppSpacing.space300,
                    AppSpacing.space500,
                    AppSpacing.space400,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary50,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.neutral100,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _guardando ? 0.0 : 1.0,
                          child: FilledButton(
                            onPressed: _guardando ? null : _guardar,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brand500,
                              foregroundColor: AppColors.neutral0,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Guardar cambios',
                              style: AppTypography.button.copyWith(
                                color: AppColors.neutral0,
                              ),
                            ),
                          ),
                        ),
                        if (_guardando)
                          const CircularProgressIndicator(
                            color: AppColors.brand500,
                          ),
                      ],
                    ),
                  ),
                ),
                ), // cierre SafeArea
              ],
            ),
    );
  }
}

// ── Opción dentro del BottomSheet ────────────────────────────────────────────
class _OpcionFoto extends StatelessWidget {
  const _OpcionFoto({
    required this.icono,
    required this.label,
    required this.onTap,
  });

  final IconData icono;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space400,
          vertical: AppSpacing.space400,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(icono, size: 24, color: AppColors.brand500),
            const SizedBox(width: AppSpacing.space400),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Campo de texto dentro del card ───────────────────────────────────────────
class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space400,
        vertical: AppSpacing.space200,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.body1.copyWith(
                color: AppColors.neutral800,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.body1.copyWith(
                  color: AppColors.neutral300,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}