import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/admin_api.dart';

class DocumentForm extends StatefulWidget {
  final AdminApi? api;
  const DocumentForm({super.key, this.api});
  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  late final api = widget.api ?? AdminApi();
  final title = TextEditingController(),
      description = TextEditingController(),
      url = TextEditingController();
  final form = GlobalKey<FormState>();
  PlatformFile? file;
  bool link = false, published = true, saving = false, loading = true;
  String? error;
  int? categoryId;
  List<Map<String, dynamic>> categories = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await api.list('/api/documents/categories');
      if (mounted) setState(() => categories = data);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Impossible de charger les catégories.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    url.dispose();
    super.dispose();
  }

  Future<void> choose() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'jpg',
        'jpeg',
        'png',
      ],
      withData: true,
    );
    if (result != null && mounted) setState(() => file = result.files.single);
  }

  String? mime(String name) {
    final ext = name.toLowerCase().split('.').last;
    return {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    }[ext];
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    if (!link &&
        (file?.bytes == null ||
            file!.size == 0 ||
            file!.size > 20 * 1024 * 1024)) {
      setState(
        () => error = 'Choisissez un fichier pris en charge de 20 Mio maximum.',
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (link) {
        await api.save('/api/documents/links', {
          'title': title.text.trim(),
          'description': description.text.trim(),
          'categoryId': categoryId,
          'published': published,
          'externalUrl': url.text.trim(),
        });
      } else {
        final data = FormData.fromMap({
          'title': title.text.trim(),
          'description': description.text.trim(),
          'published': published.toString(),
          if (categoryId != null) 'categoryId': categoryId.toString(),
          'file': MultipartFile.fromBytes(
            file!.bytes!,
            filename: file!.name,
            contentType: DioMediaType.parse(mime(file!.name)!),
          ),
        });
        await api.client.dio.post<dynamic>('/api/documents', data: data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ressource enregistrée.')));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Impossible d’ajouter cette ressource.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Documents utiles')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Fichier')),
              ButtonSegment(value: true, label: Text('Lien')),
            ],
            selected: {link},
            onSelectionChanged: (v) => setState(() => link = v.first),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: title,
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
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<int>(
              initialValue: categoryId,
              decoration: const InputDecoration(
                labelText: 'Catégorie (facultatif)',
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c['id'] as int,
                      child: Text(c['name'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => categoryId = v),
            ),
          const SizedBox(height: 16),
          if (link)
            TextFormField(
              controller: url,
              decoration: const InputDecoration(
                labelText: 'Lien',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final u = Uri.tryParse(v?.trim() ?? '');
                return u == null ||
                        !['http', 'https'].contains(u.scheme.toLowerCase()) ||
                        u.host.isEmpty ||
                        u.userInfo.isNotEmpty
                    ? 'Saisissez un lien HTTP ou HTTPS valide.'
                    : null;
              },
            )
          else
            OutlinedButton.icon(
              onPressed: choose,
              icon: const Icon(Icons.upload_file),
              label: Text(file?.name ?? 'Choisir un fichier'),
            ),
          SwitchListTile(
            title: const Text('Visible par les membres'),
            value: published,
            onChanged: (v) => setState(() => published = v),
          ),
          ElevatedButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Enregistrement…' : 'Ajouter'),
          ),
        ],
      ),
    ),
  );
}
