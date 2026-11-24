import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widget/bubbles_layer.dart';
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),
          const BubblesLayer(),
          Container(color: Colors.black.withOpacity(0.25)),
          Center(child: Image.asset('assets/pngs/logo_asaspp.png', width: 350)),
        ],
      ),
    );
  }
}
