import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../../../core/widgets/pulse_association_header.dart';
import '../../../context/data/models/association_role.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../../context/data/models/mobile_context_model.dart';

class AssociationSelectionPage extends StatefulWidget {
  final MobileContextModel mobileContext;

  const AssociationSelectionPage({super.key, required this.mobileContext});

  @override
  State<AssociationSelectionPage> createState() =>
      _AssociationSelectionPageState();
}

class _AssociationSelectionPageState extends State<AssociationSelectionPage> {
  final AuthStorage _authStorage = AuthStorage();

  MobileAssociationModel? _selectedAssociation;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _selectedAssociation = widget.mobileContext.currentAssociation;
  }

  Future<void> _continue() async {
    final association = _selectedAssociation;
    if (association == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authStorage.saveActiveAssociationId(association.associationId);
      if (mounted) context.go('/home');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de sélectionner cette association. Réessaie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final associations = widget.mobileContext.associations;
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mes associations')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                shrinkWrap: true,
                padding: PulseTheme.pagePadding,
                children: [
                  Text(
                    'Choisir une association',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionne le club que tu souhaites ouvrir.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  if (associations.isEmpty)
                    const Text('Aucune association disponible.'),
                  for (final association in associations)
                    Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        selected:
                            _selectedAssociation?.associationId ==
                            association.associationId,
                        selectedTileColor: colors.primaryContainer,
                        title: PulseAssociationHeader(
                          name: association.associationName,
                          logoUrl: association.logoUrl,
                          caption: association.role == AssociationRole.admin
                              ? 'Administrateur'
                              : 'Membre',
                        ),
                        trailing: Icon(
                          _selectedAssociation?.associationId ==
                                  association.associationId
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                        ),
                        onTap: _loading
                            ? null
                            : () => setState(
                                () => _selectedAssociation = association,
                              ),
                      ),
                    ),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: colors.error)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading || _selectedAssociation == null
                        ? null
                        : _continue,
                    child: Text(_loading ? 'Ouverture…' : 'Continuer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
