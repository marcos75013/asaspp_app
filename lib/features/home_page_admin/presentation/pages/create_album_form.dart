import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/admin_api.dart';

class CreateAlbumForm extends StatefulWidget {
  final AdminApi? api;
  const CreateAlbumForm({super.key, this.api});
  @override
  State<CreateAlbumForm> createState() => _CreateAlbumFormState();
}

class _CreateAlbumFormState extends State<CreateAlbumForm> {
  late final api = widget.api ?? AdminApi();
  final title = TextEditingController(),
      description = TextEditingController(),
      category = TextEditingController();
  final form = GlobalKey<FormState>();
  List<XFile> photos = [];
  bool saving = false, published = true;
  String? error;
  int? albumId;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    category.dispose();
    super.dispose();
  }

  Future<void> choose() async {
    final result = await ImagePicker().pickMultiImage();
    if (mounted) setState(() => photos = result);
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final files = <MultipartFile>[];
      for (final photo in photos) {
        final suffix = photo.name.toLowerCase().split('.').last;
        final type = switch (suffix) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => null,
        };
        final bytes = await photo.readAsBytes();
        if (type == null ||
            bytes.isEmpty ||
            bytes.length > 10 * 1024 * 1024 ||
            photos.length > 100) {
          if (mounted) {
            setState(
              () => error =
                  'Choisissez jusqu’à 100 images JPEG, PNG ou WebP de 10 Mio maximum.',
            );
          }
          return;
        }
        files.add(
          MultipartFile.fromBytes(
            bytes,
            filename: photo.name,
            contentType: DioMediaType.parse(type),
          ),
        );
      }
      albumId ??= await api.createAlbum({
          'title': title.text.trim(),
          'description': description.text.trim(),
          'category': category.text.trim(),
          'published': published,
        });
      if (photos.isNotEmpty) {
        await api.client.dio.post<dynamic>(
          '/api/gallery/$albumId/photos',
          data: FormData.fromMap({'files': files}),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Album enregistré.')));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = albumId == null
              ? 'Impossible de créer l’album.'
              : 'L’album est créé, mais les photos n’ont pas été envoyées. Réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Album photo')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          TextFormField(
            controller: title,
            enabled: albumId == null,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Le titre est obligatoire.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: description,
            enabled: albumId == null,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: category,
            enabled: albumId == null,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            title: const Text('Visible par les membres'),
            value: published,
            onChanged: albumId == null
                ? (v) => setState(() => published = v)
                : null,
          ),
          OutlinedButton.icon(
            onPressed: saving ? null : choose,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
              photos.isEmpty
                  ? 'Choisir des photos'
                  : '${photos.length} photo(s) sélectionnée(s)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
    ),
  );
}
