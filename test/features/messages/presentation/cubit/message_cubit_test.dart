import 'package:asaspp_app/features/messages/data/models/mobile_message_model.dart';
import 'package:asaspp_app/features/messages/data/services/mobile_message_repository.dart';
import 'package:asaspp_app/features/messages/presentation/cubit/message_cubit.dart';
import 'package:asaspp_app/features/messages/presentation/cubit/message_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMessageRepository implements MobileMessageRepository {
  final List<MobileMessageModel>? messages;

  const _FakeMessageRepository.success(this.messages);
  const _FakeMessageRepository.failure() : messages = null;

  @override
  Future<List<MobileMessageModel>> getPublishedMessages() async {
    if (messages == null) {
      throw Exception('network error');
    }

    return messages!;
  }
}

void main() {
  final message = MobileMessageModel(
    id: 7,
    title: 'Sortie club',
    content: 'Rendez-vous samedi matin.',
    authorFirstName: 'Alice',
    authorLastName: 'Martin',
    createdAt: DateTime(2026, 11, 11, 10, 30),
  );

  test('loads published messages', () async {
    final cubit = MessageCubit(
      messageRepository: _FakeMessageRepository.success([message]),
    );

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<MessageState>().having(
          (state) => state.status,
          'status',
          MessageStatus.loading,
        ),
        isA<MessageState>()
            .having((state) => state.status, 'status', MessageStatus.loaded)
            .having((state) => state.messages, 'messages', [message]),
      ]),
    );

    await cubit.loadMessages();
    await states;
    await cubit.close();
  });

  test('exposes an error state when loading fails', () async {
    final cubit = MessageCubit(
      messageRepository: const _FakeMessageRepository.failure(),
    );

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<MessageState>().having(
          (state) => state.status,
          'status',
          MessageStatus.loading,
        ),
        isA<MessageState>()
            .having((state) => state.status, 'status', MessageStatus.error)
            .having((state) => state.errorMessage, 'error message', isNotEmpty),
      ]),
    );

    await cubit.loadMessages();
    await states;
    await cubit.close();
  });

  test(
    'clears messages while refreshing so another association cannot see them',
    () async {
      final cubit = MessageCubit(
        messageRepository: _FakeMessageRepository.success([message]),
      );
      await cubit.loadMessages();
      final loading = expectLater(
        cubit.stream,
        emits(
          isA<MessageState>()
              .having((state) => state.status, 'status', MessageStatus.loading)
              .having((state) => state.messages, 'messages', isEmpty),
        ),
      );
      await cubit.loadMessages();
      await loading;
      await cubit.close();
    },
  );
}
