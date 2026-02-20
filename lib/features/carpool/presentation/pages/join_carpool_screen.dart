import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/carpool_model.dart';
import '../../widgets/carpool_card.dart';

class JoinCarpoolScreen extends StatefulWidget {
  const JoinCarpoolScreen({super.key});

  @override
  State<JoinCarpoolScreen> createState() => _JoinCarpoolScreenState();
}

class _JoinCarpoolScreenState extends State<JoinCarpoolScreen> {
  String? _selectedEvent;

  /// 🔧 MOCK DATA
  final List<CarpoolModel> _carpools = const [
    CarpoolModel(
      id: '1',
      eventName: 'Plongée fosse',
      creatorName: 'Julien',
      totalSeats: 4,
      remainingSeats: 2,
    ),
    CarpoolModel(
      id: '2',
      eventName: 'Plongée fosse',
      creatorName: 'Sophie',
      totalSeats: 3,
      remainingSeats: 0,
    ),
    CarpoolModel(
      id: '3',
      eventName: 'Plongée mer',
      creatorName: 'Marc',
      totalSeats: 5,
      remainingSeats: 1,
    ),
  ];

  List<String> get _events =>
      _carpools.map((e) => e.eventName).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final filteredCarpools = _selectedEvent == null
        ? []
        : _carpools
        .where((c) => c.eventName == _selectedEvent)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,

      /// ⬅️ APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Je m’y incruste'),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.2)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ⬇️ DROPDOWN EVENT
                        const Text(
                          'Choisir un événement',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          value: _selectedEvent,
                          items: _events
                              .map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedEvent = value);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// 📋 LISTE DES COVOITURAGES
                        if (_selectedEvent == null)
                          const Text(
                            'Sélectionne un événement pour voir les covoiturages',
                          )
                        else if (filteredCarpools.isEmpty)
                          const Text('Aucun covoiturage disponible')
                        else
                          ...filteredCarpools.map(
                                (carpool) => CarpoolCard(
                              creatorName: carpool.creatorName,
                              remainingSeats: carpool.remainingSeats,
                              onReserve: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Place réservée chez ${carpool.creatorName}',
                                    ),
                                  ),
                                );
                              },
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
