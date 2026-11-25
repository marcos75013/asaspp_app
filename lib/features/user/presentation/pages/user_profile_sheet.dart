import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../../context/data/models/association_role.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../../context/data/models/mobile_user_model.dart';
import '../../../context/cubit/context_cubit.dart';
import '../../../context/cubit/context_state.dart';
import '../../data/profile_updates.dart';
import '../../data/services/mobile_profile_api_service.dart';

class UserProfileSheet extends StatelessWidget {
  final MobileUserModel user;
  final MobileAssociationModel? association;
  final MobileProfileApiService? profileService;

  const UserProfileSheet({
    super.key,
    required this.user,
    this.association,
    this.profileService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, state) {
        final user = state.context?.user ?? this.user;
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.96),
                      Colors.white.withOpacity(0.88),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _dragHandle(),
                    const SizedBox(height: 30),
                    _ProfileAvatarControls(
                      user: user,
                      profileService: profileService,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        _roleLabel(association?.role),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _profileTile(Icons.email, "Email", user.email),
                    _profileTile(
                      Icons.phone,
                      "Téléphone",
                      user.phone ?? "Non renseigné",
                    ),
                    _profileTile(
                      Icons.diversity_3,
                      "Association active",
                      association?.associationName ?? "Non renseignée",
                    ),
                    _profileTile(
                      Icons.verified_user,
                      "Rôle",
                      _roleLabel(association?.role),
                    ),
                    const SizedBox(height: 20),
                    _actionButton(
                      "Modifier mon profil",
                      Colors.blueAccent.withOpacity(0.9),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<ContextCubit>(),
                          child: _EditProfileDialog(
                            user: user,
                            profileService: profileService,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _actionButton(
                      "Se déconnecter",
                      Colors.red.withOpacity(0.85),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 60,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, {VoidCallback? onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
      ),
      onPressed: onPressed ?? () {},
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  String _roleLabel(AssociationRole? role) {
    switch (role) {
      case AssociationRole.admin:
        return "Administrateur";
      case AssociationRole.member:
        return "Membre";
      default:
        return "Membre";
    }
  }
}

class _ProfileAvatarControls extends StatefulWidget {
  final MobileUserModel user;
  final MobileProfileApiService? profileService;
  const _ProfileAvatarControls({required this.user, this.profileService});

  @override
  State<_ProfileAvatarControls> createState() => _ProfileAvatarControlsState();
}

class _ProfileAvatarControlsState extends State<_ProfileAvatarControls> {
  late final MobileProfileApiService _profile =
      widget.profileService ??
      MobileProfileApiService(ApiClient(AuthStorage()));
  PreparedAvatar? _preview;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final user = await _profile.getProfile();
      if (mounted) context.read<ContextCubit>().updateUser(user);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Impossible de charger la photo du profil.');
    }
  }

  Future<void> _choose() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final preview = await AvatarPreparer().prepare(image);
      if (mounted) setState(() => _preview = preview);
    } catch (error) {
      if (mounted)
        setState(
          () => _error = error is AvatarPreparationException
              ? error.message
              : 'Cette image ne peut pas être convertie.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await _profile.uploadAvatar(preview);
      if (!mounted) return;
      context.read<ContextCubit>().updateUser(user);
      notifyProfileUpdated();
      setState(() => _preview = null);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Impossible d’enregistrer cette photo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await _profile.deleteAvatar();
      if (!mounted) return;
      context.read<ContextCubit>().updateUser(user);
      notifyProfileUpdated();
      setState(() => _preview = null);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Impossible de supprimer cette photo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, state) {
        final user = state.context?.user ?? widget.user;
        return Column(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: .4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: _preview == null
                    ? MemberAvatar(
                        url: user.avatarUrl,
                        name: '${user.firstName} ${user.lastName}',
                        radius: 55,
                      )
                    : CircleAvatar(
                        radius: 55,
                        backgroundImage: MemoryImage(_preview!.bytes),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_busy) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _busy ? null : _choose,
                  child: Text(
                    user.avatarUrl == null ? 'Choisir une photo' : 'Remplacer',
                  ),
                ),
                if (_preview != null)
                  TextButton(
                    onPressed: _busy ? null : _save,
                    child: const Text('Enregistrer'),
                  ),
                if (user.avatarUrl != null)
                  TextButton(
                    onPressed: _busy ? null : _delete,
                    child: const Text('Supprimer'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final MobileUserModel user;
  final MobileProfileApiService? profileService;
  const _EditProfileDialog({required this.user, this.profileService});
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.user.email);
  late final _phone = TextEditingController(text: widget.user.phone ?? '');
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  bool get _emailChanged => _email.text.trim() != widget.user.email;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user =
          await (widget.profileService ??
                  MobileProfileApiService(ApiClient(AuthStorage())))
              .updateProfile(
                email: _email.text,
                phone: _phone.text,
                currentPassword: _emailChanged ? _password.text : null,
              );
      if (!mounted) return;
      context.read<ContextCubit>().updateUser(user);
      notifyProfileUpdated();
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (mounted)
        setState(
          () => _error = e.response?.data is Map
              ? (e.response?.data['message'] as String? ??
                    'Impossible de modifier le profil.')
              : 'Impossible de modifier le profil.',
        );
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de modifier le profil.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Modifier mon profil'),
    content: Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Saisis une adresse e-mail valide.',
            ),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            if (_emailChanged)
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  helperText: 'Requis pour modifier ton e-mail de connexion.',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Saisis ton mot de passe actuel.'
                    : null,
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      ElevatedButton(
        onPressed: _busy ? null : _save,
        child: Text(_busy ? 'Enregistrement…' : 'Enregistrer'),
      ),
    ],
  );
}
