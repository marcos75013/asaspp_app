import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/models/association_role.dart';
import '../../../context/data/models/mobile_context_model.dart';
import '../../../context/data/services/mobile_context_api_service.dart';

/// Checks the current association against a freshly loaded server context.
class AdminAccessGuard extends StatefulWidget {
  final Widget child;
  final Future<bool> Function()? checkAccess;
  const AdminAccessGuard({super.key, required this.child, this.checkAccess});

  @override
  State<AdminAccessGuard> createState() => _AdminAccessGuardState();
}

class _AdminAccessGuardState extends State<AdminAccessGuard>
    with WidgetsBindingObserver {
  late Future<bool> _access;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _access = _check();
  }

  Future<bool> _check() async {
    if (widget.checkAccess != null) return widget.checkAccess!();
    final storage = AuthStorage();
    final idBefore = await storage.getActiveAssociationId();
    final context = await MobileContextApiService(
      ApiClient(storage),
    ).getContext();
    final idAfter = await storage.getActiveAssociationId();
    if (idBefore != idAfter) return false;
    return isAssociationAdmin(context, idAfter);
  }

  void _retry() => setState(() => _access = _check());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _retry();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _access,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de vérifier vos droits administrateur.'),
                TextButton(onPressed: _retry, child: const Text('Réessayer')),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Retour à l’accueil'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.data != true) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cet espace est réservé aux administrateurs de l’association.',
                ),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Retour à l’accueil'),
                ),
              ],
            ),
          ),
        );
      }
      return widget.child;
    },
  );
}

bool isAssociationAdmin(MobileContextModel context, int? activeAssociationId) {
  if (activeAssociationId == null) {
    return context.currentAssociation?.role == AssociationRole.admin;
  }
  for (final association in context.associations) {
    if (association.associationId == activeAssociationId) {
      return association.role == AssociationRole.admin;
    }
  }
  return false;
}
