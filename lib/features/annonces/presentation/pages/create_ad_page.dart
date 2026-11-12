import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/services/ads_repository.dart';
import '../data/models/ad_model.dart';

class CreateAdPage extends StatefulWidget {
  final AdsRepository repository;

  const CreateAdPage({super.key, required this.repository});

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
  AdType _type = AdType.vente;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final priceText = _priceController.text.trim().replaceAll(',', '.');
      final uploads = <AdImageUpload>[];
      for (final image in _images) {
        uploads.add(
          AdImageUpload(bytes: await image.readAsBytes(), filename: image.name),
        );
      }
      await widget.repository.createAd(
        CreateAdInput(
          type: _type,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: priceText.isEmpty ? null : double.parse(priceText),
          contactPhone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        ),
        uploads,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = "Impossible de publier l'annonce.";
      });
    }
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                            _modernField(
                              controller: _titleController,
                              label: "Titre",
                              required: true,
                            ),

                            const SizedBox(height: 20),

                            DropdownButtonFormField<AdType>(
                              initialValue: _type,
                              decoration: _fieldDecoration("Type d'annonce"),
                              items: const [
                                DropdownMenuItem(
                                  value: AdType.vente,
                                  child: Text('Vente'),
                                ),
                                DropdownMenuItem(
                                  value: AdType.recherche,
                                  child: Text('Recherche'),
                                ),
                                DropdownMenuItem(
                                  value: AdType.don,
                                  child: Text('Don'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _type = value);
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _priceController,
                              label: "Prix (€)",
                              keyboardType: TextInputType.number,
                              enabled: _type != AdType.don,
                              validator: (value) {
                                if (_type != AdType.vente) return null;
                                final price = double.tryParse(
                                  (value ?? '').replaceAll(',', '.'),
                                );
                                return price == null || price <= 0
                                    ? 'Indiquez un prix supérieur à zéro.'
                                    : null;
                              },
                            ),

                            const SizedBox(height: 20),

                            _modernField(
                              controller: _descriptionController,
                              label: "Description",
                              maxLines: 4,
                              required: true,
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
                              value: "Compte connecté",
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

                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                            ],

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
                                  onPressed: _saving ? null : _submit,
                                  child: Text(
                                    _saving
                                        ? 'Publication…'
                                        : "Publier l'annonce",
                                    style: const TextStyle(
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
    bool required = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      validator:
          validator ??
          (required
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Ce champ est obligatoire.'
                    : null
              : null),
      decoration: _fieldDecoration(label),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: const Color(0xFFF2F4F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
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
