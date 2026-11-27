import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../messages/presentation/cubit/message_cubit.dart';
import '../../../messages/presentation/cubit/message_state.dart';
import '../../../messages/data/models/mobile_message_model.dart';
import '../../../../core/widgets/member_avatar.dart';

class ClubMessageCard extends StatelessWidget {
  const ClubMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state.status == MessageStatus.loaded && state.messages.isNotEmpty) {
          return Column(
            children: [
              for (final message in state.messages)
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => _showFullMessage(context, message),
                  child: _MessageCard(
                    title: message.title,
                    content: message.content,
                    author: _messageAuthor(message),
                    avatarUrl: message.authorAvatarUrl,
                  ),
                ),
            ],
          );
        }
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

String _messageAuthor(MobileMessageModel message) {
  final signature = message.signature?.trim();
  if (signature != null && signature.isNotEmpty) return signature;
  return message.authorName.trim().isNotEmpty ? message.authorName : 'Le club';
}

void _showFullMessage(BuildContext context, MobileMessageModel message) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(message.content),
              const SizedBox(height: 20),
              Text('— ${_messageAuthor(message)}'),
            ],
          ),
        ),
      ),
    ),
  );
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MemberAvatar(radius: 18, url: avatarUrl, name: author),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(author, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
