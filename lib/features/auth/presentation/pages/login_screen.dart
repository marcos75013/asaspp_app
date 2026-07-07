import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/services/mobile_context_api_service.dart';
import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../cubit/auth_cubit.dart';
import '../data/models/mobile_auth_api_service.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// 🌊 Background mer
            Image.asset(
              'assets/pngs/bg_mer.png',
              fit: BoxFit.cover,
            ),

            /// 🫧 Bulles animées
            // const BubblesLayer(),

            /// 🌑 Voile sombre
            Container(
              color: Colors.black.withOpacity(0.35),
            ),

            /// 🧑‍🤿 Contenu centré
            const SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: LoginForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
