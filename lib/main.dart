import 'package:asaspp_app/core/network/app_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/router/app_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';

void main() {
  final secureStorageService = SecureStorageService();

  final dio = ApiClient(secureStorageService: secureStorageService).create();

  final authRemoteDataSource = AuthRemoteDataSourceImpl(dio: dio);

  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorageService: secureStorageService,
  );

  final loginUseCase = LoginUseCase(authRepository: authRepository);

  final logoutUseCase = LogoutUseCase(authRepository: authRepository);

  final checkAuthStatusUseCase = CheckAuthStatusUseCase(
    authRepository: authRepository,
  );

  runApp(
    AsasppApp(
      secureStorageService: secureStorageService,
      authRepository: authRepository,
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
    ),
  );
}

class AsasppApp extends StatelessWidget {
  const AsasppApp({
    super.key,
    required this.secureStorageService,
    required this.authRepository,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  });

  final SecureStorageService secureStorageService;
  final AuthRepository authRepository;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SecureStorageService>.value(
          value: secureStorageService,
        ),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              loginUseCase: loginUseCase,
              logoutUseCase: logoutUseCase,
              checkAuthStatusUseCase: checkAuthStatusUseCase,
            )..checkAuthStatus(),
          ),
          BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
          BlocProvider<UserCubit>(create: (_) => UserCubit()),
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
}
