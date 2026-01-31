import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/carpool/presentation/pages/create_carpool_screen.dart';
import '../../features/home/data/models/next_event_model.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/covoiturage/create',
      builder: (context, state) {
        final type = state.extra as DiveType;
        return CreateCarpoolScreen(diveType: type);
      },
    ),
  ],
);

