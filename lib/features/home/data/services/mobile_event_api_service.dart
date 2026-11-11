import '../../../../core/network/api_client.dart';
import '../models/next_event_model.dart';
import 'mobile_event_repository.dart';

class MobileEventApiService implements MobileEventRepository {
  final ApiClient _apiClient;

  MobileEventApiService(this._apiClient);

  @override
  Future<List<NextEventModel>> getFutureEvents() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/mobile/events',
      queryParameters: {'page': 0, 'size': 10},
    );
    final content = response.data?['content'] as List<dynamic>? ?? [];

    return content
        .map(
          (item) =>
              NextEventModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<NextEventModel> setParticipation(
    int eventId,
    ParticipationStatus status,
  ) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/events/$eventId/participation',
      data: {'status': participationStatusToJson(status)},
    );

    return NextEventModel.fromJson(response.data ?? {});
  }
}
