import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/auth_storage.dart';
import '../../features/connected/data/club_api.dart';

/// Transport adapter for the original screens. UI stays in its existing files.
class AssociationRepository {
  final ClubApi? injectedApi;
  AssociationRepository({this.injectedApi});
  Future<ClubApi> api() async {
    if (injectedApi != null) return injectedApi!;
    final id = await AuthStorage().getActiveAssociationId();
    if (id == null) throw StateError('Sélectionnez votre association.');
    return ClubApi(id);
  }

  Future<List<Json>> list(String path) async => (await api()).list(path);
}

AssociationRepository repositoryOf(BuildContext context) =>
    context.read<AssociationRepository>();
ImageProvider associationImage(String path) => path.startsWith('http')
    ? NetworkImage(path)
    : AssetImage(path.isEmpty ? 'assets/pngs/logo_asaspp.png' : path);

class DataStatus extends StatelessWidget {
  final bool loading;
  final String? error;
  final String empty;
  final VoidCallback reload;
  const DataStatus({
    super.key,
    required this.loading,
    this.error,
    required this.empty,
    required this.reload,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16),
    ),
    child: loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Text(
                error ?? empty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              if (error != null)
                TextButton(onPressed: reload, child: const Text('Réessayer')),
            ],
          ),
  );
}
