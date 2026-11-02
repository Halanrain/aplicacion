import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/mapa.dart';
import 'views/social.dart';
import 'views/perfil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final List<Widget> views = [
      const _InicioContent(),
      const MapaView(),
      const SocialView(),
      const PerfilView(),
    ];
    return Scaffold(
      backgroundColor: colors.surface,
      body: views[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.navigation),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          boxShadow: [AppElevation.elevation2],
        ),
        child: BottomAppBar(
          height: 64,
          padding: EdgeInsets.zero,
          color: AppColors.neutral0,
          elevation: 0,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Inicio',
                selected: _selectedIndex == 0,
                onTap: () => _onNavItemTapped(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Mapa',
                selected: _selectedIndex == 1,
                onTap: () => _onNavItemTapped(1),
              ),
              const Expanded(child: SizedBox()),
              _NavItem(
                icon: Icons.emoji_events_outlined,
                label: 'Social',
                selected: _selectedIndex == 2,
                onTap: () => _onNavItemTapped(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                selected: _selectedIndex == 3,
                onTap: () => _onNavItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InicioContent extends StatelessWidget {
  const _InicioContent();
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
              child: Text('Inicio', style: text.titleLarge),
            ),
            TabBar(
              labelColor: colors.onSurface,
              unselectedLabelColor: colors.outline,
              indicatorColor: colors.onSurface,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: colors.outline,
              tabs: const [
                Tab(text: 'Explora'),
                Tab(text: 'Desafíos'),
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
                        _PostCard(colors: colors, text: text),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space400,
                          ),
                          child: Divider(
                            height: AppSpacing.space700,
                            color: colors.outline,
                          ),
                        ),
                        _PostCard(colors: colors, text: text),
                      ],
                    ),
                  ),
                  const SizedBox.expand(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ColorScheme colors;
  final TextTheme text;
  const _PostCard({required this.colors, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person, color: colors.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: AppSpacing.space200),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alexis S. fue por un paseo',
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hace 7 días · Santiago, Chile',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Seguir'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space200),
          Text('Aquí con el Bravito', style: text.titleLarge),
          Text('No ataja ni una este hombre...', style: text.bodyMedium),
          const SizedBox(height: AppSpacing.space200),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              width: double.infinity,
              height: 220,
              color: colors.primaryContainer,
              child: const Icon(Icons.image, size: 64),
            ),
          ),
          const SizedBox(height: AppSpacing.space200),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border, color: colors.outline),
                onPressed: () {},
              ),
              const SizedBox(width: AppGap.nav),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: colors.outline),
                onPressed: () {},
              ),
              const SizedBox(width: AppGap.nav),
              IconButton(
                icon: Icon(Icons.ios_share, color: colors.outline),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? colors.primary : colors.outline),
            const SizedBox(height: 2),
            Text(
              label,
              style: text.labelSmall?.copyWith(
                color: selected ? colors.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
