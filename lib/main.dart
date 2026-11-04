import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router/app_router.dart';
import 'core/data/association_repository.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/context/cubit/context_cubit.dart';
import 'features/context/data/services/mobile_context_api_service.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';

void main() => runApp(const AsasppApp());

class AsasppApp extends StatelessWidget {
  const AsasppApp({super.key});
  @override
  Widget build(BuildContext context) => RepositoryProvider(
    create: (_) => AssociationRepository(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit(repositoryOf(context))),
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(
          create: (_) => ContextCubit(
            contextApiService: MobileContextApiService(
              ApiClient(AuthStorage()),
            ),
            authStorage: AuthStorage(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'ASASPP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    ),
  );
}
