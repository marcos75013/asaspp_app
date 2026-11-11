import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/mobile_message_repository.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MobileMessageRepository _messageRepository;

  MessageCubit({required MobileMessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const MessageState());

  Future<void> loadMessages() async {
    emit(state.copyWith(status: MessageStatus.loading, errorMessage: null));

    try {
      final messages = await _messageRepository.getPublishedMessages();
      emit(
        state.copyWith(
          status: MessageStatus.loaded,
          messages: messages,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MessageStatus.error,
          errorMessage: 'Impossible de récupérer les messages du club',
        ),
      );
    }
  }
}
