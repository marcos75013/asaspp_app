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

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
          ),
          const BubblesLayer(),
          Container(
            color: Colors.black.withOpacity(0.25),
          ),
          Center(
            child: Image.asset(
              'assets/pngs/logo_asaspp.png',
              width: 350,
            ),
          ),
        ],
      ),
    );
  }
}
