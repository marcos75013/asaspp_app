import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/context/presentation_session.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/auth_storage.dart';
import '../../features/annonces/presentation/data/models/ad_model.dart';
import '../../features/association_selection/presentation/pages/association_selection_page.dart';
import '../../features/carpool/presentation/pages/create_carpool_screen.dart';
import '../../features/carpool/presentation/pages/join_carpool_screen.dart';
import '../../features/context/data/models/mobile_context_model.dart';
import '../../features/ducumentslib/presentation/documents_library_page.dart';
import '../../features/home/data/models/next_event_model.dart';
import '../../features/home_page_admin/presentation/pages/home_page_admin.dart';
import '../../features/paiement/presentation/pages/payment_list_page.dart';
import '../../features/quiz/presentation/pages/quiz_game_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/annonces/presentation/pages/ad_detail_page.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/auth/presentation/pages/login_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) async {
    if (state.matchedLocation == '/login' || state.matchedLocation == '/splash')
      return null;
    final token = await AuthStorage().getToken();
    if (token == null || token.isEmpty) return '/login';
    if (state.matchedLocation == '/admin-home' &&
        !context.read<UserCubit>().isAdmin)
      return '/home';
    return null;
  },
  routes: applicationRoutes,
);

final List<RouteBase> applicationRoutes = [
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  GoRoute(
    path: '/home',
    builder: (context, state) => const AssociationSession(),
  ),
  GoRoute(
    path: '/association-selection',
    builder: (context, state) {
      final mobileContext = state.extra as MobileContextModel;

      return AssociationSelectionPage(mobileContext: mobileContext);
    },
  ),
  GoRoute(
    path: '/covoiturage/create',
    builder: (context, state) {
      final event = state.extra as NextEventModel;
      return CreateCarpoolScreen(event: event);
    },
  ),
  GoRoute(
    path: '/covoiturage/join',
    builder: (context, state) =>
        JoinCarpoolScreen(event: state.extra as NextEventModel?),
  ),

  GoRoute(
    path: '/annonce/detail',
    builder: (context, state) {
      final ad = state.extra as AdModel;
      return AdDetailPage(ad: ad);
    },
  ),
  GoRoute(path: '/quiz', builder: (context, state) => const QuizPage()),
  GoRoute(
    path: '/quiz/game',
    builder: (context, state) {
      final quiz = Map<String, dynamic>.from(state.extra as Map);
      return QuizGamePage(quiz: quiz);
    },
  ),
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
  ),
];
