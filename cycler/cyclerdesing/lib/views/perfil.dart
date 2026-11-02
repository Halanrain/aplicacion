import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Perfil', style: text.headlineLarge),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Vista de perfil', style: text.bodyLarge),
      ),
    );
  }
}