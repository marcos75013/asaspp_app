import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/pulse_theme.dart';
import '../../data/services/ads_repository.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_image.dart';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({super.key, required this.repository, this.imagePicker});

  final AdsRepository repository;
  final ImagePicker? imagePicker;

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  static const _maxPhotos = 5;
  final _formKey = GlobalKey<FormState>();
  late final _picker = widget.imagePicker ?? ImagePicker();
  final List<AdImageUpload> _images = [];
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  AdType _type = AdType.vente;
  bool _saving = false;
  bool _picking = false;
  String? _photoError;
  String? _submitError;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_picking || _saving || _images.length >= _maxPhotos) return;
    setState(() {
      _picking = true;
      _photoError = null;
    });
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) throw const FormatException('Empty photo');
      setState(
        () => _images.add(AdImageUpload(bytes: bytes, filename: image.name)),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _photoError = 'Impossible d’ouvrir cette photo.');
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  double? _parsePrice(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  String? _validatePrice(String? value) {
    if (_type == AdType.don) return null;
    if (_type == AdType.recherche && (value ?? '').trim().isEmpty) return null;
    final price = _parsePrice(value);
    if (price == null || !price.isFinite || price <= 0) {
      return 'Indiquez un prix supérieur à zéro.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_saving || _picking) return;
    if (!_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formContext = _formKey.currentContext;
        if (formContext != null) Scrollable.ensureVisible(formContext);
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _submitError = null;
    });

    try {
      final phone = _phoneController.text.trim();
      await widget.repository.createAd(
        CreateAdInput(
          type: _type,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: _type == AdType.don
              ? null
              : _parsePrice(_priceController.text),
          contactPhone: phone.isEmpty ? null : phone,
        ),
        List.of(_images),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _submitError = 'Impossible de publier l’annonce.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    return Theme(
      data: theme,
      child: PopScope(
        canPop: !_saving,
        child: Scaffold(
          appBar: AppBar(title: const Text('Leboncourant')),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final colors = theme.colorScheme;
                final accent = marketplaceAccent(context);
                final accentText = theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white;
                return SingleChildScrollView(
                  padding: PulseTheme.pagePadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nouvelle annonce',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _photoSection(accent, colors),
                        const SizedBox(height: 16),
                        _field(
                          controller: _titleController,
                          label: 'Titre de l’annonce',
                          hint: 'Ex. Masque de plongée',
                          colors: colors,
                          required: true,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Type d’annonce',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final (type, label) in [
                              (AdType.vente, 'Vente'),
                              (AdType.don, 'Don'),
                              (AdType.recherche, 'Recherche'),
                            ])
                              ChoiceChip(
                                label: Text(label),
                                selected: _type == type,
                                selectedColor: accent,
                                backgroundColor: colors.surface,
                                checkmarkColor: accentText,
                                labelStyle: TextStyle(
                                  color: _type == type
                                      ? accentText
                                      : colors.onSurface,
                                ),
                                onSelected: _saving
                                    ? null
                                    : (_) => setState(() => _type = type),
                              ),
                          ],
                        ),
                        if (_type != AdType.don) ...[
                          const SizedBox(height: 12),
                          _field(
                            controller: _priceController,
                            label: 'Prix (€)',
                            hint: '0,00',
                            colors: colors,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _validatePrice,
                          ),
                        ],
                        const SizedBox(height: 14),
                        _field(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Décris ton article…',
                          colors: colors,
                          maxLines: 3,
                          required: true,
                        ),
                        const SizedBox(height: 20),
                        Text('Contact', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Card(
                          margin: EdgeInsets.zero,
                          child: const ListTile(
                            leading: Icon(Icons.person_outline),
                            title: Text('Annonceur'),
                            subtitle: Text('Compte connecté'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _phoneController,
                          label: 'Numéro de téléphone',
                          hint: 'Facultatif',
                          colors: colors,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),
                        if (_submitError case final error?) ...[
                          Text(error, style: TextStyle(color: colors.error)),
                          const SizedBox(height: 8),
                        ],
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: accentText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _saving || _picking ? null : _submit,
                          child: Text(
                            _saving ? 'Publication…' : 'Publier mon annonce',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ColorScheme colors,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    FormFieldValidator<String>? validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !_saving,
      validator:
          validator ??
          (required
              ? (value) => (value ?? '').trim().isEmpty
                    ? 'Ce champ est obligatoire.'
                    : null
              : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: colors.surface,
        border: border,
        enabledBorder: border,
      ),
    );
  }

  Widget _photoSection(Color accent, ColorScheme colors) {
    final canAdd = !_saving && !_picking && _images.length < _maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          color: Color.alphaBlend(
            accent.withValues(alpha: .12),
            colors.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: canAdd ? _pickImage : null,
            leading: Icon(Icons.add_photo_alternate_outlined, color: accent),
            title: Text(
              _picking ? 'Ouverture de la galerie…' : 'Ajouter des photos',
            ),
            subtitle: Text('${_images.length}/$_maxPhotos photos'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        if (_photoError case final error?) ...[
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: colors.error)),
        ],
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 102,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: _images.length,
              onReorder: (from, to) {
                if (_saving) return;
                setState(() {
                  final image = _images.removeAt(from);
                  _images.insert(to > from ? to - 1 : to, image);
                });
              },
              itemBuilder: (context, index) {
                final image = _images[index];
                return Padding(
                  key: ObjectKey(image),
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ReorderableDelayedDragStartListener(
                      index: index,
                      enabled: !_saving,
                      child: Stack(
                        children: [
                          Image.memory(
                            Uint8List.fromList(image.bytes),
                            width: 102,
                            height: 102,
                            fit: BoxFit.cover,
                            semanticLabel: 'Photo ${index + 1}',
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 102,
                              height: 102,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              tooltip: 'Retirer la photo ${index + 1}',
                              style: IconButton.styleFrom(
                                backgroundColor: colors.surface,
                              ),
                              onPressed: _saving
                                  ? null
                                  : () => setState(() => _images.remove(image)),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_images.length > 1)
            Text(
              'Maintiens une photo pour la déplacer.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
        ],
      ],
    );
  }
}
