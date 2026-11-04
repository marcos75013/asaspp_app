import 'package:flutter/material.dart';
import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';

class MembersTrackingForm extends StatefulWidget {
  const MembersTrackingForm({super.key});
  @override
  State<MembersTrackingForm> createState() => _MembersTrackingFormState();
}

class _MembersTrackingFormState extends State<MembersTrackingForm> {
  late Future<List<Json>> _members;
  @override
  void initState() {
    super.initState();
    _members = repositoryOf(context).list('/api/admin-association/members');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Suivi des membres')),
    body: FutureBuilder<List<Json>>(
      future: _members,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(
            child: DataStatus(
              loading: snapshot.connectionState != ConnectionState.done,
              error: snapshot.hasError ? readableError(snapshot.error!) : null,
              empty: 'Aucun membre.',
              reload: () => setState(
                () => _members = repositoryOf(
                  context,
                ).list('/api/admin-association/members'),
              ),
            ),
          );
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, i) => const Divider(),
          itemBuilder: (context, i) {
            final m = snapshot.data![i];
            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('${label(m, 'firstName')} ${label(m, 'lastName')}'),
              subtitle: Text(label(m, 'email')),
              trailing: Text(label(m, 'role')),
            );
          },
        );
      },
    ),
  );
}
