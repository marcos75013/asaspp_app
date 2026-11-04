import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/connected/connected_router.dart';
import 'features/connected/presentation/club_widgets.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';

void main() {
  runApp(const AsasppApp());
}

class AsasppApp extends StatelessWidget {
  const AsasppApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!const bool.fromEnvironment('LEGACY_UI')) {
      return MaterialApp.router(
        title: 'Multi-Asso',
        debugShowCheckedModeBanner: false,
        theme: connectedTheme(),
        themeMode: ThemeMode.light,
        routerConfig: connectedRouter,
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => UserCubit()),
      ],
      child: MaterialApp.router(
        title: 'ASASPP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
