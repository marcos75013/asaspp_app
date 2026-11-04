import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'club_widgets.dart';

class ConnectedLogin extends StatefulWidget {
  const ConnectedLogin({super.key});
  @override
  State<ConnectedLogin> createState() => _ConnectedLoginState();
}

class _ConnectedLoginState extends State<ConnectedLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.authenticated) context.go('/home');
      if (state.status == AuthStatus.selectAssociation &&
          state.mobileContext != null) {
        context.go('/association-selection', extra: state.mobileContext);
      }
    },
    builder: (context, state) {
      final busy = state.status == AuthStatus.loading;
      return Scaffold(
        body: OceanBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: AutofillGroup(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              'assets/pngs/logo_asaspp.png',
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Bienvenue au club',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Connectez-vous pour retrouver votre association.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF536B80),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: _email,
                              enabled: !busy,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (value) =>
                                  value == null || !value.contains('@')
                                  ? 'Indiquez votre adresse e-mail.'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              enabled: !busy,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!busy) _submit();
                              },
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? 'Afficher le mot de passe'
                                      : 'Masquer le mot de passe',
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Indiquez votre mot de passe.'
                                  : null,
                            ),
                            if (state.status == AuthStatus.error)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  state.errorMessage ?? 'Connexion impossible.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: busy ? null : _submit,
                              child: Text(
                                busy ? 'Connexion en cours…' : 'Se connecter',
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Un espace pour chaque association. Un seul compte pour vous.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF536B80)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
