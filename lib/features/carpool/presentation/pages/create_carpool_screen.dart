import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../home/data/models/next_event_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/services/carpool_api_service.dart';
import '../carpool_departure_validation.dart';

class CreateCarpoolScreen extends StatefulWidget {
  final NextEventModel event;

  const CreateCarpoolScreen({super.key, required this.event});

  @override
  State<CreateCarpoolScreen> createState() => _CreateCarpoolScreenState();
}

class _CreateCarpoolScreenState extends State<CreateCarpoolScreen> {
  final _location = TextEditingController();
  final _seats = TextEditingController();
  final _note = TextEditingController();
  DateTime? _departureTime;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _location.dispose();
    _seats.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDeparture() async {
    final now = DateTime.now();
    final eventDate = widget.event.startDate;
    if (!eventDate.isAfter(now)) {
      setState(() => _error = 'Cet événement a déjà commencé.');
      return;
    }
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
      initialDate: _departureTime ?? eventDate,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureTime ?? eventDate),
    );
    if (time == null || !mounted) return;
    final departure = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final error = validateCarpoolDeparture(
      departure: departure,
      eventStart: eventDate,
      now: DateTime.now(),
    );
    setState(() {
      _departureTime = departure;
      _error = error;
    });
  }

  Future<void> _save() async {
    final seats = int.tryParse(_seats.text.trim());
    final departureError = validateCarpoolDeparture(
      departure: _departureTime,
      eventStart: widget.event.startDate,
      now: DateTime.now(),
    );
    if (_location.text.trim().isEmpty ||
        _location.text.trim().length > 180 ||
        seats == null ||
        seats < 1 ||
        _note.text.trim().length > 500) {
      setState(
        () => _error =
            'Renseigne un lieu (180 caractères maximum), au moins '
            'une place et un commentaire de 500 caractères maximum.',
      );
      return;
    }
    if (departureError != null) {
      setState(() => _error = departureError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CarpoolApiService(ApiClient(AuthStorage())).create(
        widget.event.id,
        departureLocation: _location.text,
        departureTime: _departureTime!,
        seatCount: seats,
        note: _note.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.response?.data is Map
              ? (error.response?.data['message'] as String? ??
                    'Impossible de créer le covoiturage.')
              : 'Impossible de créer le covoiturage.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de créer le covoiturage.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Créer un covoiturage',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌊 FOND
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low, // ⚡ optimisation GPU
          ),

          /// 🌑 VOILE
          Container(color: Colors.black.withValues(alpha: 0.25)),

          /// 📄 CONTENU
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                    /// 🎨 Effet glass optimisé (sans blur)
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.88),
                      ],
                    ),

                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EventTypeChip(title: widget.event.title),

                      const SizedBox(height: 24),

                      _FormField(
                        controller: _location,
                        label: 'Lieu de départ',
                        hint: 'Ex : Parking club, Gare, Domicile',
                        icon: Icons.place_outlined,
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: Color(0xFF34445A),
                        ),
                        title: Text(
                          _departureTime == null
                              ? 'Date et heure de départ'
                              : '${_departureTime!.day}/${_departureTime!.month}/${_departureTime!.year} '
                                    '${_departureTime!.hour.toString().padLeft(2, '0')}:'
                                    '${_departureTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFF34445A)),
                        ),
                        onTap: _pickDeparture,
                      ),

                      Text(
                        'Départ au plus tard le '
                        '${widget.event.startDate.day.toString().padLeft(2, '0')}/'
                        '${widget.event.startDate.month.toString().padLeft(2, '0')}/'
                        '${widget.event.startDate.year} à '
                        '${widget.event.startDate.hour.toString().padLeft(2, '0')}h'
                        '${widget.event.startDate.minute.toString().padLeft(2, '0')}.',
                        style: const TextStyle(color: Color(0xFF34445A)),
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        controller: _seats,
                        label: 'Places disponibles',
                        hint: 'Ex : 3',
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        controller: _note,
                        label: 'Commentaire',
                        hint: 'Coffre spacieux, retour possible…',
                        icon: Icons.chat_bubble_outline,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 28),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),

                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _saving ? 'Création…' : 'Créer le covoiturage',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF172334),
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
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF172334),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFF172334)),
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF65758A)),
            prefixIcon: Icon(icon, color: const Color(0xFF65758A)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTypeChip extends StatelessWidget {
  final String title;

  const _EventTypeChip({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
