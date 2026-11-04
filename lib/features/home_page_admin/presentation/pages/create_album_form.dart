import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';
import 'package:flutter/material.dart';

class CreateAlbumForm extends StatefulWidget {
  const CreateAlbumForm({super.key});

  @override
  State<CreateAlbumForm> createState() => _CreateAlbumFormState();
}

class _CreateAlbumFormState extends State<CreateAlbumForm> {
  final _title = TextEditingController();
  List<PlatformFile> _files = [];
  int? _createdAlbumId;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.pickFiles(
        withData: true,
        allowMultiple: true,
        type: FileType.image,
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
    if (_files.length > 100) throw StateError('Maximum 100 photos.');
    final parts = <MultipartFile>[];
    for (final f in _files) {
      final bytes = f.bytes;
      if (bytes == null || bytes.isEmpty)
        throw StateError('Le fichier est vide ou illisible.');
      final mime =
          lookupMimeType(f.name, headerBytes: bytes) ??
          'application/octet-stream';
      if (bytes.length > 10 * 1024 * 1024 ||
          !['image/jpeg', 'image/png', 'image/webp'].contains(mime))
        throw StateError('Photos JPEG, PNG ou WebP, 10 Mo maximum.');
      parts.add(
        MultipartFile.fromBytes(
          bytes,
          filename: f.name,
          contentType: DioMediaType.parse(mime),
        ),
      );
    }
    final api = await repositoryOf(context).api();
    if (_createdAlbumId == null) {
      final result = await api.request(
        '/api/gallery',
        method: 'POST',
        query: {'title': _title.text.trim(), 'published': true},
      );
      _createdAlbumId = result['id'] as int;
    }
    if (parts.isNotEmpty)
      await api.request(
        '/api/gallery/$_createdAlbumId/photos',
        method: 'POST',
        data: FormData.fromMap({'files': parts}),
      );
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un album photo")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "Nom de l'album",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saving ? null : _pick,
              child: const Text("Ajouter des photos"),
            ),

            if (_files.isNotEmpty) Text(_files.map((f) => f.name).join(', ')),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: const Text("Créer l'album"),
            ),
          ],
        ),
      ),
    );
  }
}
