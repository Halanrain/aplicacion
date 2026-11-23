import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        await _guardarPerfilSiNuevo(user);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  Future<void> _guardarPerfilSiNuevo(User user) async {
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      final partes = (user.displayName ?? '').trim().split(' ');
      final nombre = partes.isNotEmpty ? partes.first : '';
      final apellido =
          partes.length > 1 ? partes.sublist(1).join(' ') : '';

      await docRef.set({
        'nombre': nombre,
        'apellido': apellido,
        'foto': '',
        'email': user.email ?? '',
        'seguidores': 0,
        'siguiendo': 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.brand500,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/icons/iconlauncher.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: AppSpacing.space400),
              Text(
                'Cycler',
                style: text.displaySmall?.copyWith(
                  color: AppColors.neutral0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space200),
              Text(
                'Tus rutas, tus paisajes.',
                style: text.bodyLarge?.copyWith(
                  color: AppColors.neutral0.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: _isLoading ? 0.0 : 1.0,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.neutral0,
                          foregroundColor: AppColors.brand600,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        icon: SvgPicture.asset(
                          'assets/icons/icon-google.svg',
                          width: 20,
                          height: 20,
                          colorFilter: null,
                        ),
                        label: Text(
                          'Continuar con Google',
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand600,
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: AppColors.neutral0,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space400),
            ],
          ),
        ),
      ),
    );
  }
}