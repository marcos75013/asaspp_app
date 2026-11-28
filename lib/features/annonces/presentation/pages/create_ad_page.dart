import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/pulse_theme.dart';
import '../../../../core/widgets/pulse_gradient_heading.dart';
import '../../../../core/widgets/pulse_page_header.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../data/services/ads_repository.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_image.dart';

class CreateAdPage extends StatefulWidget {
  const CreateAdPage({
    super.key,
    required this.repository,
    this.imagePicker,
    this.ad,
    this.association,
  });

  final AdsRepository repository;
  final ImagePicker? imagePicker;
  final AdModel? ad;
  final MobileAssociationModel? association;

  @override
  State<CreateAdPage> createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  static const _maxPhotos = 5;
  final _formKey = GlobalKey<FormState>();
  late final _picker = widget.imagePicker ?? ImagePicker();
  final List<AdImageUpload> _images = [];
  late final _titleController = TextEditingController(text: widget.ad?.title);
  late final _priceController = TextEditingController(
    text:
        widget.ad == null ||
            widget.ad!.type == AdType.recherche && widget.ad!.price == 0
        ? null
        : widget.ad!.price.toString().replaceAll('.', ','),
  );
  late final _descriptionController = TextEditingController(
    text: widget.ad?.description,
  );
  late final _phoneController = TextEditingController(
    text: widget.ad?.contactPhone,
  );
  late AdType _type = widget.ad?.type ?? AdType.vente;
  late final _existingPhotos = [...?widget.ad?.photos];
  final _removedPhotoIds = <int>[];
  bool _photoOrderChanged = false;
  bool get _editing => widget.ad != null;
  int get _photoCount => _existingPhotos.length + _images.length;
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
    if (_picking || _saving || _photoCount >= _maxPhotos) return;
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
    if (_saving || _picking || widget.ad?.isOwner == false) return;
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
      final input = CreateAdInput(
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _type == AdType.don ? null : _parsePrice(_priceController.text),
        contactPhone: phone.isEmpty ? null : phone,
      );
      if (widget.ad case final ad?) {
        await widget.repository.updateAd(ad.id, input);
        await _savePhotoChanges(ad.id);
      } else {
        await widget.repository.createAd(input, List.of(_images));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _submitError = _editing
            ? 'Enregistrement incomplet. Réessaie pour terminer les modifications.'
            : 'Impossible de publier l’annonce.';
      });
    }
  }

  Future<void> _savePhotoChanges(String id) async {
    // Upload first when there is room, so a failed upload keeps existing photos.
    while (_images.isNotEmpty &&
        _removedPhotoIds.isNotEmpty &&
        _existingPhotos.length + _removedPhotoIds.length + _images.length >
            _maxPhotos) {
      await widget.repository.deleteAdImage(id, _removedPhotoIds.first);
      _removedPhotoIds.removeAt(0);
    }

    if (_images.isNotEmpty) {
      final updated = await widget.repository.addAdImages(id, List.of(_images));
      final knownIds = {
        for (final photo in _existingPhotos) photo.id,
        ..._removedPhotoIds,
      };
      _existingPhotos.addAll(
        updated.photos.where((photo) => !knownIds.contains(photo.id)),
      );
      _images.clear();
    }

    while (_removedPhotoIds.isNotEmpty) {
      await widget.repository.deleteAdImage(id, _removedPhotoIds.first);
      _removedPhotoIds.removeAt(0);
    }

    if (_photoOrderChanged && _existingPhotos.length > 1) {
      await widget.repository.reorderAdImages(id, [
        for (final photo in _existingPhotos) photo.id!,
      ]);
      _photoOrderChanged = false;
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
          appBar: PulsePageHeader(
            title: 'Leboncourant',
            associationName: widget.association?.associationName,
            logoUrl: widget.association?.logoUrl,
            backEnabled: !_saving,
          ),
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
                        if (_editing)
                          Text(
                            'Modifier mon annonce',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        else
                          const PulseGradientHeading(
                            prefix: 'Nouvelle',
                            accent: 'annonce',
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
                        if (!_editing) ...[
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
                        ],
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
                        if (!_editing) ...[
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
                        ],
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
                          onPressed:
                              _saving || _picking || widget.ad?.isOwner == false
                              ? null
                              : _submit,
                          child: Text(
                            _saving
                                ? (_editing
                                      ? 'Enregistrement…'
                                      : 'Publication…')
                                : (_editing
                                      ? 'Enregistrer les modifications'
                                      : 'Publier mon annonce'),
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

  void _movePhoto(int from, int to) {
    if (_saving || from == to || to < 0 || to >= _images.length) return;
    setState(() {
      final image = _images.removeAt(from);
      _images.insert(to, image);
    });
  }

  void _moveExistingPhoto(int from, int to) {
    if (_saving || to < 0 || to >= _existingPhotos.length) return;
    setState(() {
      _existingPhotos.insert(to, _existingPhotos.removeAt(from));
      _photoOrderChanged = true;
    });
  }

  Widget _photoArrows({
    required String label,
    required int index,
    required int count,
    required ValueChanged<int> moveTo,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Déplacer la photo $label vers la gauche',
          onPressed: _saving || index == 0 ? null : () => moveTo(index - 1),
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(
          tooltip: 'Déplacer la photo $label vers la droite',
          onPressed: _saving || index == count - 1
              ? null
              : () => moveTo(index + 1),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  Widget _photoSection(Color accent, ColorScheme colors) {
    final canAdd = !_saving && !_picking && _photoCount < _maxPhotos;
    final canReorder = _images.length > 1;
    final canReorderPublished =
        _existingPhotos.length > 1 &&
        _existingPhotos.every((photo) => photo.id != null);
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
            subtitle: Text('$_photoCount/$_maxPhotos photos'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        if (_photoError case final error?) ...[
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: colors.error)),
        ],
        if (_existingPhotos.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, photo) in _existingPhotos.indexed)
                SizedBox(
                  width: 102,
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: 102,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AdImage(url: photo.url),
                              if (index == 0)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  right: 4,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        'Couverture',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (photo.id case final id?)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    tooltip:
                                        'Retirer la photo publiée ${index + 1}',
                                    style: IconButton.styleFrom(
                                      backgroundColor: colors.surface,
                                    ),
                                    onPressed: _saving
                                        ? null
                                        : () => setState(() {
                                            _existingPhotos.remove(photo);
                                            _removedPhotoIds.add(id);
                                          }),
                                    icon: const Icon(Icons.close, size: 18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (canReorderPublished)
                        _photoArrows(
                          label: 'publiée ${index + 1}',
                          index: index,
                          count: _existingPhotos.length,
                          moveTo: (to) => _moveExistingPhoto(index, to),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        if (canReorderPublished)
          Text(
            'La première photo sert de couverture.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: canReorder ? 150 : 102,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: _images.length,
              onReorder: (from, to) =>
                  _movePhoto(from, to > from ? to - 1 : to),
              itemBuilder: (context, index) {
                final image = _images[index];
                return Padding(
                  key: ObjectKey(image),
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 102,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ReorderableDelayedDragStartListener(
                            index: index,
                            enabled: canReorder && !_saving,
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
                                        : () => setState(
                                            () => _images.remove(image),
                                          ),
                                    icon: const Icon(Icons.close, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (canReorder)
                          _photoArrows(
                            label: '${index + 1}',
                            index: index,
                            count: _images.length,
                            moveTo: (to) => _movePhoto(index, to),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (canReorder)
            Text(
              'Utilise les flèches sous les photos pour changer leur ordre.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
        ],
      ],
    );
  }
}
