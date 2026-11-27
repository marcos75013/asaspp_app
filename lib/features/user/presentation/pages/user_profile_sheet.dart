import '../../../../core/theme/pulse_theme.dart';
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
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, state) {
        final user = state.context?.user ?? this.user;
        return Theme(
          data: theme,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (sheetContext, controller) => Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: controller,
                  padding: PulseTheme.pagePadding,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mes informations',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fermer',
                          onPressed: () =>
                              Navigator.of(sheetContext).maybePop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ProfileAvatarControls(
                      user: user,
                      profileService: profileService,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user.firstName} ${user.lastName}'.trim(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    _profileTile(
                      Icons.email_outlined,
                      'Email',
                      user.email,
                      colors,
                    ),
                    _profileTile(
                      Icons.phone_outlined,
                      'Téléphone',
                      user.phone ?? 'Non renseigné',
                      colors,
                    ),
                    _profileTile(
                      Icons.groups_outlined,
                      'Association active',
                      association?.associationName ?? 'Non renseignée',
                      colors,
                    ),
                    _profileTile(
                      Icons.verified_user_outlined,
                      'Rôle',
                      _roleLabel(association?.role),
                      colors,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier mon profil'),
                      onPressed: () => showDialog<void>(
                        context: sheetContext,
                        builder: (_) => Theme(
                          data: theme,
                          child: BlocProvider.value(
                            value: context.read<ContextCubit>(),
                            child: _EditProfileDialog(
                              user: user,
                              profileService: profileService,
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
        );
      },
    );
  }

  Widget _profileTile(
    IconData icon,
    String title,
    String value,
    ColorScheme colors,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(title, style: TextStyle(color: colors.onSurfaceVariant)),
      subtitle: Text(
        value,
        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
      ),
    ),
  );

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
      if (mounted) {
        setState(() => _error = 'Impossible de charger la photo du profil.');
      }
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
      if (mounted) {
        setState(
          () => _error = error is AvatarPreparationException
              ? error.message
              : 'Cette image ne peut pas être convertie.',
        );
      }
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
      if (mounted) {
        setState(() => _error = 'Impossible d’enregistrer cette photo.');
      }
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
      if (mounted) {
        setState(() => _error = 'Impossible de supprimer cette photo.');
      }
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
            if (_preview == null)
              MemberAvatar(
                url: user.avatarUrl,
                name: '${user.firstName} ${user.lastName}',
                radius: 42,
              )
            else
              CircleAvatar(
                radius: 42,
                backgroundImage: MemoryImage(_preview!.bytes),
              ),
            const SizedBox(height: 12),
            if (_busy) const CircularProgressIndicator(),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
      if (mounted) {
        setState(
          () => _error = e.response?.data is Map
              ? (e.response?.data['message'] as String? ??
                    'Impossible de modifier le profil.')
              : 'Impossible de modifier le profil.',
        );
      }
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
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Saisis une adresse e-mail valide.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
            ),
            if (_emailChanged)
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                  helperText: 'Requis pour modifier ton e-mail de connexion.',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Saisis ton mot de passe actuel.'
                    : null,
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: _busy ? null : _save,
        child: Text(_busy ? 'Enregistrement…' : 'Enregistrer'),
      ),
    ],
  );
}
