import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
import 'editorPerfil.dart';
import 'settings.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fila título + iconos (igual que social.dart) ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space400,
                AppSpacing.space400,
                AppSpacing.space400,
                AppSpacing.space200,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Perfil',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _ProfileHeaderIcon(
                    asset: 'assets/icons/icon-notification.svg',
                    semanticLabel: 'Notificaciones',
                  ),
                  const SizedBox(width: 12),
                  _ProfileHeaderIcon(
                    asset: 'assets/icons/icon-settings.svg',
                    semanticLabel: 'Configuración',
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SettingsView(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space600,
                0,
                AppSpacing.space600,
                0,
              ),
              child: uid == null
                  ? const SizedBox.shrink()
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final nombre = data?['nombre'] as String? ?? '';
                        final apellido = data?['apellido'] as String? ?? '';
                        final nombreCompleto =
                            '$nombre $apellido'.trim().isEmpty
                                ? 'Usuario'
                                : '$nombre $apellido'.trim();
                        final seguidores =
                            (data?['seguidores'] as int? ?? 0).toString();
                        final siguiendo =
                            (data?['siguiendo'] as int? ?? 0).toString();
                        final foto = data?['foto'] as String? ?? '';

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileAvatar(
                              foto: foto,
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const EditorPerfilView(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space400),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombreCompleto,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.subtitle1.copyWith(
                                      color: AppColors.neutral800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space200),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      _ProfileStat(
                                        label: 'Seguidores',
                                        value: seguidores,
                                      ),
                                      const SizedBox(
                                          width: AppSpacing.space500),
                                      _ProfileStat(
                                        label: 'Siguiendo',
                                        value: siguiendo,
                                      ),
                                      const Spacer(),
                                      const _AddPersonButton(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.space400),
            TabBar(
              labelColor: colors.onSurface,
              unselectedLabelColor: colors.outline,
              indicatorColor: colors.onSurface,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: colors.outline,
              tabs: const [
                Tab(text: 'Sobre mi'),
                Tab(text: 'Publicaciones'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [_AboutProfileTab(), SizedBox.expand()],
              ),
            ),
          ],
        ),
        ), // cierre DefaultTabController
      ), // cierre SafeArea
    );
  }
}

class _AboutProfileTab extends StatelessWidget {
  const _AboutProfileTab();

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space400),
        children: const [
          Text('Trayectorias', style: AppTypography.subtitle1),
          SizedBox(height: AppSpacing.space300),
          _TrajectoriesRow(),
          SizedBox(height: AppSpacing.space700),
          _ProfileMetricsGrid(),
          SizedBox(height: AppSpacing.space700),
          _CollectionsSection(),
        ],
      ),
    );
  }
}

class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Colecciones',
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space300),
        const _CreateCollectionButton(),
      ],
    );
  }
}

class _CreateCollectionButton extends StatelessWidget {
  const _CreateCollectionButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Crear una nueva colección',
      button: true,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: SizedBox(
          width: 128,
          height: 84,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 20, color: AppColors.neutral500),
              const SizedBox(height: AppSpacing.space100),
              Text(
                'Crea una nueva',
                style: AppTypography.body2.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutral500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.lg),
        ),
      );
    final metric = path.computeMetrics().first;
    const dashLength = 3.0;
    const gapLength = 3.0;
    for (
      var distance = 0.0;
      distance < metric.length;
      distance += dashLength + gapLength
    ) {
      canvas.drawPath(
        metric.extractPath(
          distance,
          (distance + dashLength).clamp(0, metric.length),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

class _TrajectoriesRow extends StatelessWidget {
  const _TrajectoriesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _AddTrajectoryButton(),
          SizedBox(width: AppSpacing.space200),
          _TrajectoryThumbnail(),
          SizedBox(width: AppSpacing.space200),
          _TrajectoryThumbnail(),
          SizedBox(width: AppSpacing.space200),
          _TrajectoryThumbnail(),
        ],
      ),
    );
  }
}

class _AddTrajectoryButton extends StatelessWidget {
  const _AddTrajectoryButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Agregar trayectoria',
      button: true,
      child: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          color: AppColors.brand500,
          shape: BoxShape.circle,
          boxShadow: [AppElevation.elevation2],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, size: 28, color: AppColors.neutral0),
      ),
    );
  }
}

class _TrajectoryThumbnail extends StatelessWidget {
  const _TrajectoryThumbnail();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trayectoria guardada',
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neutral200, width: 1),
        ),
      ),
    );
  }
}

class _ProfileMetricsGrid extends StatelessWidget {
  const _ProfileMetricsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.space200,
      mainAxisSpacing: AppSpacing.space200,
      childAspectRatio: 2.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ProfileMetricCard(
          value: '2',
          label: 'Rutas guardadas',
          icon: Icons.route_outlined,
        ),
        _ProfileMetricCard(
          value: '2',
          label: 'Favoritos',
          icon: Icons.star_border,
        ),
        _ProfileMetricCard(
          value: '25',
          label: 'Contribuciones',
          icon: Icons.edit_note_outlined,
        ),
        _ProfileMetricCard(
          value: '6',
          label: 'Recorridos hechos',
          icon: Icons.flag_outlined,
        ),
      ],
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space300,
        vertical: AppSpacing.space200,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: const [AppElevation.elevation1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                value,
                style: AppTypography.h5.copyWith(color: AppColors.neutral800),
              ),
              const Spacer(),
              Icon(icon, size: 20, color: AppColors.neutral700),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar de perfil ────────────────────────────────────────────────────────
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.foto = '', this.onTap});

  final String foto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Foto de perfil',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutral100,
                  border: Border.all(color: AppColors.brand500, width: 1.5),
                ),
                child: ClipOval(
                  child: foto.isNotEmpty
                      ? Image.network(
                          foto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.person,
                              size: 28,
                              color: AppColors.neutral500,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: AppColors.neutral500,
                          ),
                        ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.accent500,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/icon-edit.svg',
                    width: 10,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      AppColors.neutral0,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body2.copyWith(color: AppColors.neutral800),
        ),
        Text(
          value,
          style: AppTypography.subtitle1.copyWith(color: AppColors.neutral800),
        ),
      ],
    );
  }
}

class _AddPersonButton extends StatelessWidget {
  const _AddPersonButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Agregar persona',
      button: true,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/icon-person-add.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.neutral800,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderIcon extends StatelessWidget {
  const _ProfileHeaderIcon({
    required this.asset,
    required this.semanticLabel,
    this.onTap,
  });

  final String asset;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCAD0DA)),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(asset, width: 22, height: 22),
        ),
      ),
    );
  }
}