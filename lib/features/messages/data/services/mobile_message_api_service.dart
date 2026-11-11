import '../../../../core/network/api_client.dart';
import '../models/mobile_message_model.dart';
import 'mobile_message_repository.dart';

class MobileMessageApiService implements MobileMessageRepository {
  final ApiClient _apiClient;

  MobileMessageApiService(this._apiClient);

  @override
  Future<List<MobileMessageModel>> getPublishedMessages() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/mobile/messages',
    );

    return (response.data ?? [])
        .map(
          (item) => MobileMessageModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
