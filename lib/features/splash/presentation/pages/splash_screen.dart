import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widget/bubbles_layer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏱️ Splash ASASPP
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌊 IMAGE DE FOND
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
          ),

          /// 🫧 BULLES ANIMÉES
          const BubblesLayer(),

          /// 🌑 VOILE POUR LISIBILITÉ
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          /// 🐠 LOGO CENTRÉ (PLUS GRAND)
          Center(
            child: Image.asset(
              'assets/pngs/logo_asaspp.png',
              width: 650, // ⬅️ plus grand qu’avant
            ),
          ),
        ],
      ),
    );
  }
}
