import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

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
            Expanded(
              child: TabBarView(
                children: [
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space400,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.space400,
                            0,
                            AppSpacing.space400,
                            AppSpacing.space200,
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.neutral0,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: const [AppElevation.elevation1],
                            ),
                            child: TextField(
                              style: AppTypography.body1,
                              textAlignVertical: TextAlignVertical.center,
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
                        ),
                        const _ContactSection(
                          label: 'Ver contactos de Facebook',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space600,
                          ),
                          child: Divider(
                            height: AppSpacing.space400,
                            color: colors.outline,
                          ),
                        ),
                        const _ContactSection(
                          label: 'Ver contactos de Instagram',
                        ),
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
                      ],
                    ),
                  ),
                  const _FriendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        .where((friend) => friend.name.toLowerCase().contains(_query))
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
              onChanged: (value) => setState(() {
                _query = value.trim().toLowerCase();
              }),
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