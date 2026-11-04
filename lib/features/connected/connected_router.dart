import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/data/models/mobile_auth_api_service.dart';
import '../context/cubit/context_cubit.dart';
import '../context/data/models/mobile_context_model.dart';
import '../context/data/models/association_role.dart';
import '../context/data/services/mobile_context_api_service.dart';
import 'presentation/club_shell.dart';
import 'presentation/club_widgets.dart';
import 'presentation/login_page.dart';

final connectedRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) async {
    final token = await AuthStorage().getToken();
    if ((token == null || token.isEmpty) && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) {
          final storage = AuthStorage();
          final client = ApiClient(storage);
          return AuthCubit(
            authApiService: MobileAuthApiService(client),
            contextApiService: MobileContextApiService(client),
            authStorage: storage,
          );
        },
        child: const ConnectedLogin(),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (_) {
          final storage = AuthStorage();
          return ContextCubit(
            contextApiService: MobileContextApiService(ApiClient(storage)),
            authStorage: storage,
          )..loadContext();
        },
        child: const ClubShell(),
      ),
    ),
    GoRoute(
      path: '/association-selection',
      builder: (context, state) {
        final data = state.extra;
        if (data is! MobileContextModel) return const _ReloadSelection();
        return Scaffold(
          appBar: AppBar(title: const Text('Mes associations')),
          body: PageBody(
            children: [
              const Heading(
                'Où allons-nous ?',
                'Choisissez votre association pour continuer.',
              ),
              ...data.associations.map(
                (association) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: const CircleAvatar(
                      backgroundColor: mint,
                      child: Icon(Icons.groups_outlined, color: teal),
                    ),
                    title: Text(association.associationName),
                    subtitle: Text(association.role.label),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      await AuthStorage().saveActiveAssociationId(
                        association.associationId,
                      );
                      if (context.mounted) context.go('/home');
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/home'),
        child: const Text('Revenir à mon association'),
      ),
    ),
  ),
);

class _ReloadSelection extends StatelessWidget {
  const _ReloadSelection();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/home'),
        child: const Text('Retrouver mes associations'),
      ),
    ),
  );
}
