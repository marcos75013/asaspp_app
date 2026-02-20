import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
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
            const BubblesLayer(),

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
