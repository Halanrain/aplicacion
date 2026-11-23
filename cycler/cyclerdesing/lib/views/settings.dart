import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          '¿Cerrar sesión?',
          style: AppTypography.h6.copyWith(color: AppColors.neutral800),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: AppTypography.body1.copyWith(color: AppColors.neutral500),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.space400,
          0,
          AppSpacing.space400,
          AppSpacing.space400,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space300,
                    ),
                  ),
                  child: Text(
                    'No',
                    style: AppTypography.button.copyWith(
                      color: AppColors.neutral600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space300),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error500,
                    foregroundColor: AppColors.neutral0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space300,
                    ),
                  ),
                  child: Text(
                    'Sí, cerrar',
                    style: AppTypography.button.copyWith(
                      color: AppColors.neutral0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración',
          style: AppTypography.subtitle1.copyWith(color: AppColors.neutral800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space400,
            vertical: AppSpacing.space200,
          ),
          children: [
            // ── Tarjeta de perfil (datos reales de Firestore) ────────────
            if (uid != null)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final nombre = data?['nombre'] as String? ?? '';
                  final apellido = data?['apellido'] as String? ?? '';
                  final nombreCompleto = '$nombre $apellido'.trim().isEmpty
                      ? 'Ciclista'
                      : '$nombre $apellido'.trim();
                  final foto = data?['foto'] as String? ?? '';
                  final email =
                      FirebaseAuth.instance.currentUser?.email ?? '';

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.space400),
                    decoration: BoxDecoration(
                      color: AppColors.neutral0,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: const [AppElevation.elevation1],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brand100,
                            border: Border.all(
                              color: AppColors.brand500,
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: foto.isNotEmpty
                                ? Image.network(
                                    foto,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: AppColors.brand500,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 24,
                                    color: AppColors.brand500,
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space300),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCompleto,
                                style: AppTypography.subtitle1.copyWith(
                                  color: AppColors.neutral800,
                                ),
                              ),
                              Text(
                                email,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.neutral400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.space500),

            // ── PREFERENCIAS ─────────────────────────────────────────────
            _SettingsSection(
              title: 'PREFERENCIAS',
              items: [
                _SettingsItem(label: 'Notificaciones', onTap: () {}),
                _SettingsItem(
                  label: 'Unidades de medida',
                  subtitle: 'Kilómetros',
                  onTap: () {},
                ),
                _SettingsItem(
                  label: 'Idioma',
                  subtitle: 'Español',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space400),

            // ── PRIVACIDAD ───────────────────────────────────────────────
            _SettingsSection(
              title: 'PRIVACIDAD',
              items: [
                _SettingsItem(label: 'Privacidad del perfil', onTap: () {}),
                _SettingsItem(
                  label: 'Datos y actividad',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space400),

            // ── SOPORTE ──────────────────────────────────────────────────
            _SettingsSection(
              title: 'SOPORTE',
              items: [
                _SettingsItem(label: 'Centro de ayuda', onTap: () {}),
                _SettingsItem(
                  label: 'Acerca de Cycler',
                  subtitle: 'Versión 0.1.0',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space700),

            // ── CERRAR SESIÓN ────────────────────────────────────────────
            _SignOutButton(onTap: () => _confirmSignOut(context)),

            const SizedBox(height: AppSpacing.space600),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.space200,
            bottom: AppSpacing.space200,
          ),
          child: Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.neutral400,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: const [AppElevation.elevation1],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.showDivider = true,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space400,
              vertical: AppSpacing.space300,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.neutral800,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.neutral300,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.space400,
            color: AppColors.neutral100,
          ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space400),
        decoration: BoxDecoration(
          color: AppColors.error50,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.error200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20, color: AppColors.error500),
            const SizedBox(width: AppSpacing.space200),
            Text(
              'Cerrar sesión',
              style: AppTypography.button.copyWith(
                color: AppColors.error500,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}