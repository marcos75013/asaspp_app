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
        }

        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(state.errorMessage ?? 'Erreur de connexion'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.75),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/pngs/logo_asaspp.png',
                    width: 120,
                    filterQuality: FilterQuality.low,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                              }
                            },
                      child: isLoading
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Champ requis';
        }

        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        prefixIcon: Icon(
          icon,
          color: Colors.blueGrey,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}