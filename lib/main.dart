import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/pulse_appearance.dart';
import 'features/user/presentation/cubit/user_cubit.dart';

void main() {
  runApp(const AsasppApp());
}

class AsasppApp extends StatefulWidget {
  const AsasppApp({super.key});

  @override
  State<AsasppApp> createState() => _AsasppAppState();
}

class _AsasppAppState extends State<AsasppApp> {
  final _appearance = PulseAppearance();

  @override
  void initState() {
    super.initState();
    _appearance.restore(() => mounted).catchError((Object _) {});
  }

  @override
  void dispose() {
    _appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PulseAppearanceScope(
    appearance: _appearance,
    child: BlocProvider(
      create: (_) => UserCubit(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _appearance,
        builder: (context, mode, _) => MaterialApp.router(
          title: 'ASASPP',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          routerConfig: appRouter,
        ),
      ),
    ),
  );
}
