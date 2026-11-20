import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.selectAssociation &&
            state.mobileContext != null) {
          context.go('/association-selection', extra: state.mobileContext);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(state.errorMessage ?? 'Erreur'),
            ),
          );
        }
      },
      builder: (context, state) => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/pngs/logo_multiasso.png', width: 300),
            const SizedBox(height: 56),
            _field(
              controller: _emailController,
              hint: 'Adresse e-mail',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            _field(
              controller: _passwordController,
              hint: 'Mot de passe',
              icon: Icons.lock_outline,
              obscure: !_passwordVisible,
              autofillHints: const [AutofillHints.password],
              suffixIcon: IconButton(
                tooltip: _passwordVisible
                    ? 'Masquer le mot de passe'
                    : 'Afficher le mot de passe',
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  _passwordVisible = !_passwordVisible;
                }),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1263F6), Color(0xFF7135F5)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                          }
                        },
                  child: state.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    Widget? suffixIcon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      obscureText: obscure,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF68808C)),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE4EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE4EF)),
        ),
      ),
    );
  }
}
