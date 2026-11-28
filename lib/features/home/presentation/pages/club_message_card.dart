import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../messages/presentation/cubit/message_cubit.dart';
import '../../../messages/presentation/cubit/message_state.dart';
import '../../../messages/data/models/mobile_message_model.dart';
import '../../../../core/widgets/member_avatar.dart';

class ClubMessageCard extends StatelessWidget {
  const ClubMessageCard({super.key, this.showMessageLabel = false});

  final bool showMessageLabel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state.status == MessageStatus.loaded && state.messages.isNotEmpty) {
          return Column(
            children: [
              for (final message in state.messages)
                _MessageCard(
                  onTap: () => _showFullMessage(context, message),
                  title: message.title,
                  content: message.content,
                  author: _messageAuthor(message),
                  avatarUrl: message.authorAvatarUrl,
                  showMessageLabel: showMessageLabel,
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
  final VoidCallback? onTap;
  final bool showMessageLabel;

  const _MessageCard({
    required this.title,
    required this.content,
    required this.author,
    required this.avatarUrl,
    this.onTap,
    this.showMessageLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(author, style: theme.textTheme.labelLarge),
                        if (showMessageLabel)
                          Text(
                            'Message du club',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: showMessageLabel ? FontWeight.w700 : null,
                ),
              ),
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
      ),
    );
  }
}
