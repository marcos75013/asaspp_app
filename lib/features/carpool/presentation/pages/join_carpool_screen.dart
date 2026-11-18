import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/carpool_model.dart';
import '../../data/services/carpool_api_service.dart';
import '../../widgets/carpool_card.dart';
import '../../../home/data/models/next_event_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';

class JoinCarpoolScreen extends StatefulWidget {
  final NextEventModel event;
  const JoinCarpoolScreen({super.key, required this.event});

  @override
  State<JoinCarpoolScreen> createState() => _JoinCarpoolScreenState();
}

class _JoinCarpoolScreenState extends State<JoinCarpoolScreen> {
  late final CarpoolApiService _api = CarpoolApiService(
    ApiClient(AuthStorage()),
  );
  List<CarpoolModel> _carpools = const [];
  bool _loading = true;
  String? _error;
  int? _busyPostId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _carpools = const [];
    });
    try {
      final posts = await _api.list(widget.event.id);
      if (mounted) {
        setState(
          () => _carpools = posts
              .where((post) => post.active && post.type == 'OFFER')
              .toList(),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger les covoiturages.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBooking(CarpoolModel carpool) async {
    setState(() {
      _busyPostId = carpool.id;
      _error = null;
    });
    try {
      if (carpool.bookedByCurrentUser) {
        await _api.cancelBooking(carpool.id);
      } else {
        await _api.book(carpool.id);
      }
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de modifier la réservation.');
      }
    } finally {
      if (mounted) setState(() => _busyPostId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(color: Colors.black.withValues(alpha: 0.2)),

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
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Événement',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.event.title),

                        const SizedBox(height: 24),

                        /// 📋 LISTE DES COVOITURAGES
                        if (_loading)
                          const Center(child: CircularProgressIndicator())
                        else if (_error != null)
                          TextButton(onPressed: _load, child: Text(_error!))
                        else if (_carpools.isEmpty)
                          const Text('Aucun covoiturage disponible')
                        else
                          ..._carpools.map(
                            (carpool) => CarpoolCard(
                              creatorName: carpool.creatorName,
                              remainingSeats: carpool.remainingSeats,
                              avatarUrl: carpool.authorAvatarUrl,
                              booked: carpool.bookedByCurrentUser,
                              enabled:
                                  !carpool.ownedByCurrentUser &&
                                  _busyPostId != carpool.id,
                              onReserve: () => _toggleBooking(carpool),
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
