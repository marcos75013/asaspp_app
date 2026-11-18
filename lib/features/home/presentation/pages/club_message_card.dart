import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../messages/presentation/cubit/message_cubit.dart';
import '../../../messages/presentation/cubit/message_state.dart';
import '../../../../core/widgets/member_avatar.dart';

class ClubMessageCard extends StatelessWidget {
  const ClubMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        final message = state.messages.firstOrNull;
        final title = message?.title.trim().isNotEmpty == true
            ? message!.title
            : 'Message du club';
        final content = switch (state.status) {
          MessageStatus.initial ||
          MessageStatus.loading => 'Chargement du message…',
          MessageStatus.error => 'Le message du club est indisponible.',
          MessageStatus.loaded when message == null =>
            'Aucun message du club pour le moment.',
          _ => message!.content,
        };
        final author = message?.authorName.trim().isNotEmpty == true
            ? message!.authorName
            : 'Le club';

        return _MessageCard(
          title: title,
          content: content,
          author: author,
          avatarUrl: message?.authorAvatarUrl,
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String? avatarUrl;

  const _MessageCard({
    required this.title,
    required this.content,
    required this.author,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 245,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF2B174F), Color(0xFF151B45), Color(0xFF061329)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Color(0xFF9B6CFF), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B6CFF).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned(
                  right: 20,
                  top: 18,
                  child: Text(
                    '“',
                    style: TextStyle(
                      color: const Color(0xFF7DFFFF).withValues(alpha: 0.32),
                      fontSize: 88,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),

                Positioned(
                  right: -32,
                  bottom: -28,
                  child: Icon(
                    Icons.water_rounded,
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),

                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7DFFFF),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withValues(alpha: 0.42),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: MemberAvatar(
                              radius: 28,
                              url: avatarUrl,
                              name: author,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Text(
                        content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "— $author",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }
}
