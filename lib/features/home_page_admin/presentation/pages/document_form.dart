import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';
import 'package:flutter/material.dart';

class DocumentForm extends StatefulWidget {
  const DocumentForm({super.key});

  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final _title = TextEditingController();
  List<PlatformFile> _files = [];
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.any,
      );
      if (result != null && mounted) setState(() => _files = result.files);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    }
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
    if (_title.text.trim().isEmpty) throw StateError('Renseignez le titre.');
    if (_files.length != 1) throw StateError('Choisissez un document.');
    final parts = <MultipartFile>[];
    for (final f in _files) {
      final bytes = f.bytes;
      if (bytes == null || bytes.isEmpty)
        throw StateError('Le fichier est vide ou illisible.');
      final mime =
          lookupMimeType(f.name, headerBytes: bytes) ??
          'application/octet-stream';

      parts.add(
        MultipartFile.fromBytes(
          bytes,
          filename: f.name,
          contentType: DioMediaType.parse(mime),
        ),
      );
    }
    final api = await repositoryOf(context).api();
    await api.request(
      '/api/documents',
      method: 'POST',
      data: FormData.fromMap({
        'title': _title.text.trim(),
        'published': true,
        'file': parts.single,
      }),
    );
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un document")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "Nom du document",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _pick,
              child: const Text("Uploader document"),
            ),

            if (_files.isNotEmpty) Text(_files.map((f) => f.name).join(', ')),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
