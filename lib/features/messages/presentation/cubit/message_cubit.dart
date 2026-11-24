import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/mobile_message_repository.dart';
import 'message_state.dart';
import '../../../user/data/profile_updates.dart';

class MessageCubit extends Cubit<MessageState> {
  final MobileMessageRepository _messageRepository;
  int _requestId = 0;

  MessageCubit({required MobileMessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const MessageState()) {
    profileUpdates.addListener(loadMessages);
  }

  @override
  Future<void> close() {
    profileUpdates.removeListener(loadMessages);
    return super.close();
  }

  Future<void> loadMessages() async {
    final requestId = ++_requestId;
    emit(const MessageState(status: MessageStatus.loading));

    try {
      final messages = await _messageRepository.getPublishedMessages();
      if (isClosed || requestId != _requestId) return;
      emit(
        state.copyWith(
          status: MessageStatus.loaded,
          messages: messages,
          errorMessage: null,
        ),
      );
    } catch (_) {
      if (isClosed || requestId != _requestId) return;
      emit(
        state.copyWith(
          status: MessageStatus.error,
          errorMessage: 'Impossible de récupérer les messages du club',
        ),
      );
    }
  }
}
