import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import 'package:image_picker/image_picker.dart';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key});

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  String get _sellerName {
    final user = context.read<UserCubit>().state;
    return '${user.prenom} ${user.nom}';
  }

  bool _busy = false;
  int? _createdId;
  String _type = 'SALE';
  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
      if (_type == 'SALE' && (price == null || price < 0))
        throw StateError('Indiquez un prix valide.');
      final api = await repositoryOf(context).api();
      final uploads = <MultipartFile>[];
      for (final image in _images) {
        final name = image.name.toLowerCase();
        final mime = name.endsWith('.png')
            ? 'image/png'
            : name.endsWith('.webp')
            ? 'image/webp'
            : name.endsWith('.jpg') || name.endsWith('.jpeg')
            ? 'image/jpeg'
            : null;
        if (mime == null || await image.length() > 5 * 1024 * 1024)
          throw StateError('Photos JPEG, PNG ou WebP, 5 Mo maximum.');
        uploads.add(
          MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: image.name,
            contentType: DioMediaType.parse(mime),
          ),
        );
      }
      final saved = await api.request(
        _createdId == null
            ? '/api/marketplace'
            : '/api/marketplace/$_createdId',
        method: _createdId == null ? 'POST' : 'PUT',
        data: {
          'type': _type,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': _type == 'SALE' ? price : null,
          'contactPhone': _phoneController.text.trim(),
        },
      );
      _createdId = saved['id'] as int;
      if (uploads.isNotEmpty)
        await api.request(
          '/api/marketplace/$_createdId/images',
          method: 'POST',
          data: FormData.fromMap({'files': uploads}),
        );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Stack(
        children: [
          /// 🔵 HEADER GRADIENT
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4D8), Color(0xFF0A1E2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔙 HEADER CONTENT
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Nouvelle annonce",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 💎 CARD FLOTTANTE
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _type,
                              items: const [
                                DropdownMenuItem(
                                  value: 'SALE',
                                  child: Text('Vente'),
                                ),
                                DropdownMenuItem(
                                  value: 'GIFT',
                                  child: Text('Don'),
                                ),
                                DropdownMenuItem(
                                  value: 'WANTED',
                                  child: Text('Recherche'),
                                ),
                              ],
                              onChanged: _busy
                                  ? null
                                  : (value) => setState(() => _type = value!),
                            ),
                            const SizedBox(height: 20),
                            _modernField(
                              controller: _titleController,
                              label: "Titre",
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _priceController,
                              label: "Prix (€)",
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _descriptionController,
                              label: "Description",
                              maxLines: 4,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Contact",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _readOnlyModern(
                              label: "Annonceur",
                              value: _sellerName,
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _phoneController,
                              label: "Numéro de téléphone",
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Images",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _imageBox(),

                            const SizedBox(height: 40),

                            /// 🚀 BOUTON PREMIUM
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00B4D8),
                                      Color(0xFF0A1E2D),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                  ),
                                  onPressed: _busy ? null : _publish,
                                  child: const Text(
                                    "Publier l'annonce",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _readOnlyModern({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE9EDF2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _imageBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _images.removeAt(oldIndex);
                _images.insert(newIndex, item);
              });
            },
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              /// ➕ BOUTON AJOUT
              if (index == _images.length) {
                return Container(
                  key: const ValueKey("add"),
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final image = _images[index];

              return Container(
                key: ValueKey(image.path),
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    /// IMAGE
                    Container(
                      width: 100,
                      child: FutureBuilder<Uint8List>(
                        future: image.readAsBytes(),
                        builder: (context, snapshot) => snapshot.hasData
                            ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                            : const SizedBox(),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    /// ❌ DELETE
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    /// DRAG HANDLE
                    const Positioned(
                      bottom: 6,
                      left: 6,
                      child: Icon(
                        Icons.drag_indicator,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "${_images.length}/5 photos — Maintenez et glissez pour réorganiser",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
