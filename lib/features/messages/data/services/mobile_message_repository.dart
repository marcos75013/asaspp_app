import '../models/mobile_message_model.dart';

abstract interface class MobileMessageRepository {
  Future<List<MobileMessageModel>> getPublishedMessages();
}
