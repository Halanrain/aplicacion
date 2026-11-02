import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SocialView extends StatelessWidget {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Social', style: text.headlineLarge),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Vista social', style: text.bodyLarge),
      ),
    );
  }
}