import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClubMessageCard extends StatefulWidget {
  const ClubMessageCard({super.key});

  @override
  State<ClubMessageCard> createState() => _ClubMessageCardState();
}

class _ClubMessageCardState extends State<ClubMessageCard> {
  String _message = 'Aucun message disponible.';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!context.read<UserCubit>().isAdmin) return;
    try {
      final messages = await repositoryOf(
        context,
      ).list('/api/admin-association/messages');
      final published = messages
          .where((m) => m['published'] == true)
          .firstOrNull;
      if (mounted && published != null)
        setState(() => _message = label(published, 'content'));
    } catch (_) {
      if (mounted)
        setState(
          () => _message = 'Le message du club est momentanément indisponible.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: const SizedBox(
                            width: 46,
                            height: 46,
                            child: Icon(Icons.campaign, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "Message du président",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// MESSAGE
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// SIGNATURE
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "— Votre association",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }
}
