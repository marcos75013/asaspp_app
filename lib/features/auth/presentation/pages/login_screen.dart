import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/services/mobile_context_api_service.dart';
import '../cubit/auth_cubit.dart';
import '../data/models/mobile_auth_api_service.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    return Theme(
      data: theme,
      child: BlocProvider(
        create: (_) {
          final authStorage = AuthStorage();
          final apiClient = ApiClient(authStorage);
          final authApiService = MobileAuthApiService(apiClient);
          final contextApiService = MobileContextApiService(apiClient);

          return AuthCubit(
            authApiService: authApiService,
            contextApiService: contextApiService,
            authStorage: authStorage,
          );
        },
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 440),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
