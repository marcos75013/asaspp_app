import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../../context/data/models/mobile_context_model.dart';

class AssociationSelectionPage extends StatefulWidget {
  final MobileContextModel mobileContext;

  const AssociationSelectionPage({
    super.key,
    required this.mobileContext,
  });

  @override
  State<AssociationSelectionPage> createState() =>
      _AssociationSelectionPageState();
}

class _AssociationSelectionPageState extends State<AssociationSelectionPage> {
  final AuthStorage _authStorage = AuthStorage();

  MobileAssociationModel? _selectedAssociation;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.mobileContext.associations.isNotEmpty) {
      _selectedAssociation = widget.mobileContext.associations.first;
    }
  }

  Future<void> _continue() async {
    final association = _selectedAssociation;

    if (association == null) return;

    setState(() => _loading = true);

    await _authStorage.saveActiveAssociationId(association.associationId);

    if (!mounted) return;

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final associations = widget.mobileContext.associations;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.35),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/pngs/logo_asaspp.png',
                          height: 110,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Choisir une association',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF062B4F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sélectionne l’association que tu souhaites ouvrir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5B6472),
                          ),
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<MobileAssociationModel>(
                          value: _selectedAssociation,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Association',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          items: associations.map((association) {
                            return DropdownMenuItem<MobileAssociationModel>(
                              value: association,
                              child: Text(
                                association.associationName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAssociation = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B74C9),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Continuer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}