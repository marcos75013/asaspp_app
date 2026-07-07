import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../features/annonces/presentation/data/models/ad_model.dart';
import '../../features/association_selection/presentation/pages/association_selection_page.dart';
import '../../features/carpool/presentation/pages/create_carpool_screen.dart';
import '../../features/carpool/presentation/pages/join_carpool_screen.dart';
import '../../features/context/cubit/context_cubit.dart';
import '../../features/context/data/models/mobile_context_model.dart';
import '../../features/context/data/services/mobile_context_api_service.dart';
import '../../features/ducumentslib/presentation/documents_library_page.dart';
import '../../features/home/data/models/next_event_model.dart';
import '../../features/home_page_admin/presentation/pages/home_page_admin.dart';
import '../../features/paiement/presentation/pages/payment_list_page.dart';
import '../../features/quiz/presentation/pages/quiz_game_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../main_scaffold.dart';
import '../../features/annonces/presentation/pages/ad_detail_page.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/auth/presentation/pages/login_screen.dart';




final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final authStorage = AuthStorage();
        final apiClient = ApiClient(authStorage);
        final contextApiService = MobileContextApiService(apiClient);

        return BlocProvider(
          create: (_) => ContextCubit(
            contextApiService: contextApiService,
            authStorage: authStorage,
          )..loadContext(),
          child: const MainScaffold(),
        );
      },
    ),
    GoRoute(
      path: '/association-selection',
      builder: (context, state) {
        final mobileContext = state.extra as MobileContextModel;

        return AssociationSelectionPage(
          mobileContext: mobileContext,
        );
      },
    ),
    GoRoute(
      path: '/covoiturage/create',
      builder: (context, state) {
        final type = state.extra as DiveType;
        return CreateCarpoolScreen(diveType: type);
      },
    ),
    GoRoute(
      path: '/covoiturage/join',
      builder: (context, state) => const JoinCarpoolScreen(),
    ),

    GoRoute(
      path: '/annonce/detail',
      builder: (context, state) {
        final ad = state.extra as AdModel;
        return AdDetailPage(ad: ad);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizPage(),
    ),
    GoRoute(
      path: '/quiz/game',
      builder: (context, state) {
        final level = state.extra as int;
        return QuizGamePage(level: level);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentsLibraryPage(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentListPage(),
    ),
    GoRoute(
      path: '/admin-home',
      builder: (context, state) => const HomePageAdmin(),
    )





  ],
);
