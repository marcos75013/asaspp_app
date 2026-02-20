// import 'dart:async';
// import 'package:flutter/material.dart';
//
// import '../../features/splash/presentation/pages/splash_screen.dart';
// import '../../main_scaffold.dart';
//
//
// class AppEntry extends StatefulWidget {
//   const AppEntry({super.key});
//
//   @override
//   State<AppEntry> createState() => _AppEntryState();
// }
//
// class _AppEntryState extends State<AppEntry> {
//   bool _showSplash = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ⏱️ Splash ASASPP = 5 secondes
//     Timer(const Duration(seconds: 3), () {
//       if (!mounted) return;
//       setState(() {
//         _showSplash = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 500),
//       switchInCurve: Curves.easeOut,
//       switchOutCurve: Curves.easeIn,
//       child: _showSplash
//           ? const SplashScreen()
//           : const MainScaffold(),
//     );
//   }
// }
