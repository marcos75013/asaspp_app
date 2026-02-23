import 'package:flutter/material.dart';
import '../../../home/data/models/next_event_model.dart';

class CreateCarpoolScreen extends StatelessWidget {
  final DiveType diveType;

  const CreateCarpoolScreen({
    super.key,
    required this.diveType,
  });

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
          Container(color: Colors.black.withOpacity(0.25)),

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
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.88),
                      ],
                    ),

                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EventTypeChip(type: diveType),

                      const SizedBox(height: 24),

                      _FormField(
                        label: 'Lieu de départ',
                        hint: 'Ex : Parking club, Gare, Domicile',
                        icon: Icons.place_outlined,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'Heure de départ',
                        hint: 'Ex : 07h30',
                        icon: Icons.access_time,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'Places disponibles',
                        hint: 'Ex : 3',
                        icon: Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      _FormField(
                        label: 'Commentaire',
                        hint: 'Coffre spacieux, retour possible…',
                        icon: Icons.chat_bubble_outline,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 28),

                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Créer le covoiturage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _FormField({
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
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
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
  final DiveType type;

  const _EventTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _labelForDiveType(type),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _labelForDiveType(DiveType type) {
  switch (type) {
    case DiveType.mer:
      return 'Plongée mer';
    case DiveType.fosse:
      return 'Fosse';
    case DiveType.piscine:
      return 'Piscine';
    case DiveType.carriere:
      return 'Carrière';
    case DiveType.apero:
      return 'Apéro';
    case DiveType.formation:
      return 'Formation';
    case DiveType.stage:
      return 'Stage';
  }
}
