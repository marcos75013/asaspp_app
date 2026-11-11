import '../../data/models/mobile_message_model.dart';

enum MessageStatus { initial, loading, loaded, error }

class MessageState {
  final MessageStatus status;
  final List<MobileMessageModel> messages;
  final String? errorMessage;

  const MessageState({
    this.status = MessageStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<MobileMessageModel>? messages,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}
