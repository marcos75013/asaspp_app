import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';
import 'package:flutter/material.dart';

class WriteMessageForm extends StatefulWidget {
  const WriteMessageForm({super.key});

  @override
  State<WriteMessageForm> createState() => _WriteMessageFormState();
}

class _WriteMessageFormState extends State<WriteMessageForm> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool _saving = false;
  Future<void> save(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _submit() => save(() async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty)
      throw StateError('Renseignez le titre et le message.');
    await (await repositoryOf(context).api()).request(
      '/api/admin-association/messages',
      method: 'POST',
      data: {
        'title': _title.text.trim(),
        'content': _body.text.trim(),
        'published': true,
      },
    );
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Message association")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _body,
              decoration: const InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: const Text("Envoyer"),
            ),
          ],
        ),
      ),
    );
  }
}
