import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

// ── Modelo liviano de usuario ────────────────────────────────────────────────
class _UsuarioResultado {
  const _UsuarioResultado({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.foto,
  });

  final String uid;
  final String nombre;
  final String apellido;
  final String foto;

  String get nombreCompleto => '$nombre $apellido'.trim();
}

// ════════════════════════════════════════════════════════════════════════════
//  SocialView
// ════════════════════════════════════════════════════════════════════════════
class SocialView extends StatelessWidget {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space400,
                AppSpacing.space400,
                AppSpacing.space400,
                AppSpacing.space200,
              ),
              child: Text('Social', style: text.titleLarge),
            ),
            TabBar(
              labelColor: colors.onSurface,
              unselectedLabelColor: colors.outline,
              indicatorColor: colors.onSurface,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: colors.outline,
              tabs: const [
                Tab(text: 'Buscar amigos'),
                Tab(text: 'Mis amigos'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _BuscarAmigosTab(),
                  _FriendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tab "Buscar amigos"
// ════════════════════════════════════════════════════════════════════════════
class _BuscarAmigosTab extends StatefulWidget {
  const _BuscarAmigosTab();

  @override
  State<_BuscarAmigosTab> createState() => _BuscarAmigosTabState();
}

class _BuscarAmigosTabState extends State<_BuscarAmigosTab> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _buscando = false;
  String _query = '';
  List<_UsuarioResultado> _resultados = [];
  bool _cargando = false;

  // Vistos recientemente — persiste durante la sesión
  static final List<_UsuarioResultado> _recientes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _cancelarBusqueda() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _buscando = false;
      _query = '';
      _resultados = [];
      _cargando = false;
    });
  }

  Future<void> _buscar(String value) async {
    final q = value.trim().toLowerCase();
    setState(() {
      _query = q;
      _resultados = [];
    });

    if (q.isEmpty) return;

    setState(() => _cargando = true);

    try {
      final myUid = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .limit(60)
          .get();

      if (!mounted) return;

      final resultados = snapshot.docs
          .where((doc) => doc.id != myUid)
          .map((doc) {
            final data = doc.data();
            return _UsuarioResultado(
              uid: doc.id,
              nombre: data['nombre'] as String? ?? '',
              apellido: data['apellido'] as String? ?? '',
              foto: data['foto'] as String? ?? '',
            );
          })
          .where((u) => u.nombreCompleto.toLowerCase().contains(q))
          .toList();

      setState(() {
        _resultados = resultados;
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _agregarARecientes(_UsuarioResultado usuario) {
    setState(() {
      _recientes.removeWhere((u) => u.uid == usuario.uid);
      _recientes.insert(0, usuario);
      if (_recientes.length > 10) _recientes.removeLast();
    });
  }

  void _quitarDeRecientes(String uid) {
    setState(() => _recientes.removeWhere((u) => u.uid == uid));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Barra de búsqueda FIJA (fuera del scroll) ───────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space400,
            AppSpacing.space400,
            AppSpacing.space400,
            AppSpacing.space200,
          ),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neutral0,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppElevation.elevation1],
            ),
            child: Row(
              children: [
                // Ícono como hermano del TextField, nunca como prefixIcon
                GestureDetector(
                  onTap: _buscando ? _cancelarBusqueda : null,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: _buscando
                          ? const Icon(
                              Icons.arrow_back,
                              size: 22,
                              color: AppColors.neutral600,
                            )
                          : SvgPicture.asset(
                              'assets/icons/icon-search.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                ),
                // TextField sin prefixIcon
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppTypography.body1,
                    textAlignVertical: TextAlignVertical.center,
                    onTap: () {
                      if (!_buscando) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _buscando = true);
                        });
                      }
                    },
                    onChanged: _buscar,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre',
                      hintStyle: AppTypography.body1.copyWith(
                        color: AppColors.neutral500,
                      ),
                      filled: true,
                      fillColor: AppColors.neutral0,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space300),
              ],
            ),
          ),
        ),

        // ── Contenido scrolleable debajo de la barra ────────────────────
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.space400),
              children: [
                if (!_buscando) ...[
                  const _ContactSection(label: 'Ver contactos de Facebook'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space600,
                    ),
                    child: Divider(
                      height: AppSpacing.space400,
                      color: colors.outline,
                    ),
                  ),
                  const _ContactSection(label: 'Ver contactos de Instagram'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space600,
                    ),
                    child: Divider(
                      height: AppSpacing.space400,
                      color: colors.outline,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space600,
                      AppSpacing.space200,
                      AppSpacing.space600,
                      AppSpacing.space300,
                    ),
                    child: Text(
                      'PERSONAS QUE PUEDES CONOCER',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
                  const _SuggestedPerson(
                    name: 'Felipe Camiroaga',
                    subtitle: '20 horas - Santiago, Chile',
                  ),
                  const _SuggestedPerson(
                    name: 'Mauricio Durán',
                    subtitle: '20 horas - Santiago, Chile',
                  ),
                  const _SuggestedPerson(
                    name: 'Jorge González',
                    subtitle: '20 horas - Santiago, Chile',
                  ),
                  const _SuggestedPerson(
                    name: 'Mario Kreutzberger',
                    subtitle: '20 horas - Santiago, Chile',
                  ),
                ] else ...[
                  // ── Resultados ─────────────────────────────────────────
                  if (_query.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space600,
                        AppSpacing.space100,
                        AppSpacing.space600,
                        AppSpacing.space200,
                      ),
                      child: Text(
                        'Resultados',
                        style: AppTypography.subtitle1.copyWith(
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    if (_cargando)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.space500),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brand500,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else if (_resultados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space600,
                          0,
                          AppSpacing.space600,
                          AppSpacing.space400,
                        ),
                        child: Text(
                          'No se encontraron usuarios.',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      )
                    else
                      for (final usuario in _resultados)
                        _ResultadoUsuario(
                          usuario: usuario,
                          mostrarX: false,
                          onTap: () => _agregarARecientes(usuario),
                        ),
                  ],

                  // ── Vistos recientemente ───────────────────────────────
                  if (_recientes.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.space600,
                        _query.isNotEmpty
                            ? AppSpacing.space500
                            : AppSpacing.space100,
                        AppSpacing.space600,
                        AppSpacing.space200,
                      ),
                      child: Text(
                        'Vistos recientemente',
                        style: AppTypography.subtitle1.copyWith(
                          color: AppColors.neutral800,
                        ),
                      ),
                    ),
                    for (final usuario in _recientes)
                      _ResultadoUsuario(
                        usuario: usuario,
                        mostrarX: true,
                        onDismiss: () => _quitarDeRecientes(usuario.uid),
                      ),
                  ] else if (_query.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space600,
                        AppSpacing.space400,
                        AppSpacing.space600,
                        0,
                      ),
                      child: Text(
                        'Escribe el nombre de la persona que buscas.',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Fila de resultado / reciente ─────────────────────────────────────────────
class _ResultadoUsuario extends StatelessWidget {
  const _ResultadoUsuario({
    required this.usuario,
    required this.mostrarX,
    this.onTap,
    this.onDismiss,
  });

  final _UsuarioResultado usuario;
  final bool mostrarX;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space500,
          vertical: AppSpacing.space300,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand100,
                border: Border.all(color: AppColors.brand500, width: 1.5),
              ),
              child: ClipOval(
                child: usuario.foto.isNotEmpty
                    ? Image.network(
                        usuario.foto,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 22,
                          color: AppColors.brand500,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 22,
                        color: AppColors.brand500,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.space300),
            // Nombre
            Expanded(
              child: Text(
                usuario.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body1.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
            ),
            // Botón X (solo para recientes)
            if (mostrarX && onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space300),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tab "Mis amigos"
// ════════════════════════════════════════════════════════════════════════════
class _FriendsTab extends StatefulWidget {
  const _FriendsTab();

  @override
  State<_FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<_FriendsTab> {
  static const _friends = [
    _Friend(
      name: 'Alexis Sánchez',
      message: 'buena compa todo bien?',
      time: '19:20',
      read: true,
    ),
    _Friend(
      name: 'Juan Carlos',
      message: 'cuando salimos a correr...',
      time: '19:20',
      read: false,
    ),
    _Friend(
      name: 'José Antonio',
      message: 'el otro día te vi en la...',
      time: '19:20',
      read: true,
    ),
    _Friend(
      name: 'Jimmy McGill',
      message: 'te defenderé la próxima',
      time: '19:20',
      read: false,
    ),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visibleFriends = _friends
        .where((f) => f.name.toLowerCase().contains(_query))
        .toList();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space400,
          AppSpacing.space400,
          AppSpacing.space400,
          0,
        ),
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.neutral0,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppElevation.elevation1],
            ),
            child: TextField(
              style: AppTypography.body1,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                hintStyle: AppTypography.body1.copyWith(
                  color: AppColors.neutral500,
                ),
                prefixIcon: SvgPicture.asset(
                  'assets/icons/icon-search.svg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.scaleDown,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                filled: true,
                fillColor: AppColors.neutral0,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space300,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space300),
          for (final friend in visibleFriends) _FriendListTile(friend: friend),
        ],
      ),
    );
  }
}

class _Friend {
  const _Friend({
    required this.name,
    required this.message,
    required this.time,
    required this.read,
  });

  final String name;
  final String message;
  final String time;
  final bool read;
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend});

  final _Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space200),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brand500, width: 2),
            ),
          ),
          const SizedBox(width: AppSpacing.space300),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: AppSpacing.space050),
                Row(
                  children: [
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: friend.read
                          ? AppColors.brand400
                          : AppColors.neutral400,
                    ),
                    const SizedBox(width: AppSpacing.space100),
                    Expanded(
                      child: Text(
                        friend.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space200),
          Text(
            friend.time,
            style: AppTypography.body2.copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Widgets reutilizables
// ════════════════════════════════════════════════════════════════════════════
class _SuggestedPerson extends StatelessWidget {
  const _SuggestedPerson({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space400,
        vertical: AppSpacing.space100,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space400,
          vertical: AppSpacing.space200,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand500, width: 2),
              ),
            ),
            const SizedBox(width: AppSpacing.space400),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space400),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.brand500,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space300,
                  vertical: AppSpacing.space100,
                ),
                child: Text(
                  'Seguir',
                  style: AppTypography.button.copyWith(
                    color: AppColors.neutral0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space400,
        vertical: AppSpacing.space100,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            label.contains('Facebook')
                ? 'assets/icons/icon-facebook.svg'
                : 'assets/icons/icon-instagram.svg',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: AppSpacing.space200),
          Text(
            label,
            style: AppTypography.body1.copyWith(
              color: AppColors.neutral800,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}