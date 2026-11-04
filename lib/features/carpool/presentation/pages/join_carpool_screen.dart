import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../../home/data/models/next_event_model.dart';
import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/carpool_model.dart';
import '../../widgets/carpool_card.dart';

class JoinCarpoolScreen extends StatefulWidget {
  final NextEventModel? event;
  const JoinCarpoolScreen({super.key, this.event});

  @override
  State<JoinCarpoolScreen> createState() => _JoinCarpoolScreenState();
}

class _JoinCarpoolScreenState extends State<JoinCarpoolScreen> {
  String? _selectedEvent;

  List<CarpoolModel> _carpools = [];
  bool _loading = false;
  String? _error;
  final Set<String> _pending = {};
  List<NextEventModel> get _events =>
      context.read<HomeCubit>().state.nextEvents.values.toList();
  @override
  void initState() {
    super.initState();
    _selectedEvent = widget.event?.id.toString();
    if (_selectedEvent != null) _load();
  }

  Future<void> _load() async {
    final selected = _selectedEvent;
    if (selected == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await repositoryOf(
        context,
      ).list('/api/events/$selected/carpools');
      if (mounted && selected == _selectedEvent)
        setState(() {
          _carpools = rows
              .where((r) => r['type'] == 'OFFER')
              .map(
                (r) => CarpoolModel(
                  id: '${r['id']}',
                  eventName: selected,
                  creatorName:
                      '${label(r, 'authorFirstName')} ${label(r, 'authorLastName')}',
                  totalSeats: r['seatCount'] as int,
                  remainingSeats: (r['availableSeatCount'] as num).toInt(),
                  booked: r['bookedByCurrentUser'] == true,
                  owned: r['ownedByCurrentUser'] == true,
                  departure:
                      '${label(r, 'departureLocation')} · ${label(r, 'departureTime').replaceAll('T', ' ')}',
                ),
              )
              .toList();
          _loading = false;
        });
    } catch (error) {
      if (mounted && selected == _selectedEvent)
        setState(() {
          _error = readableError(error);
          _loading = false;
        });
    }
  }

  Future<void> _reserve(CarpoolModel trip) async {
    if (!_pending.add(trip.id)) return;
    try {
      final api = await repositoryOf(context).api();
      await api.request(
        '/api/carpools/${trip.id}${trip.booked ? '/bookings/mine' : '/bookings'}',
        method: trip.booked ? 'DELETE' : 'POST',
      );
      if (mounted) await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(error))));
    } finally {
      _pending.remove(trip.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCarpools = _selectedEvent == null
        ? []
        : _carpools.where((c) => c.eventName == _selectedEvent).toList();

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
          Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),
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
                          initialValue: _selectedEvent,
                          items: _events
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.id.toString(),
                                  child: Text(e.site),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedEvent = value);
                            _load();
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
                        if (_loading || _error != null)
                          DataStatus(
                            loading: _loading,
                            error: _error,
                            empty: '',
                            reload: _load,
                          )
                        else if (_selectedEvent == null)
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
                              booked: carpool.booked,
                              owned: carpool.owned,
                              departure: carpool.departure,
                              onReserve: () => _reserve(carpool),
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
