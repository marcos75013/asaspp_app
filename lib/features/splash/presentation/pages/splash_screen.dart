import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/pulse_theme.dart';
import '../../../../core/storage/auth_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final storage = AuthStorage();
    final session = await storage.getSession();
    final associationId = await storage.getActiveAssociationId();
    if (!mounted) return;
    context.go(
      session.token != null && associationId != null ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset('assets/pngs/logo_multiasso.png', width: 180),
          ),
        ),
      ),
    );
  }
}
